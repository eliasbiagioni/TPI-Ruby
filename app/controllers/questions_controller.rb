class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :update, :destroy]
  before_action :authenticate_request, only: [:create, :update, :destroy]
  attr_reader :current_user

  # GET /questions
  def index
      case params[:sort]
      when "pending_first"
        @questions = QuestionSerializer.new(Question.order(status: :asc).limit(50))
      when "needing_first"
        @questions = QuestionSerializer.new(Question.where(status: false).limit(50))
      else
        @questions = QuestionSerializer.new(Question.order(created_at: :asc).limit(50))
      end

    render json: @questions
  end

  # GET /questions/1
  def show
    if(params.include?("answers"))
      render json: QuestionSerializer.new(@question, {params: {complete: true},include: ['answers'] })
    else
      render json: QuestionSerializer.new(@question, {params: {complete: true}})
    end
  end

  # POST /questions
  def create
    user = JsonWebToken.decode(request.headers['X-QA-Key'])
    @question = Question.new(question_params.merge({user_id: user[:user_id]}))
    if @question.save
      render json: QuestionSerializer.new(@question), status: :created, location: @question
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /questions/1
  def update
    user = JsonWebToken.decode(request.headers['X-QA-Key'])
    if (user[:user_id] == @question[:user_id])
      if @question.update(question_params)
        render json: QuestionSerializer.new(@question)
      else
        render json: @question.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Not Authorized' }, status: 401
    end
  end

  # DELETE /questions/1
  def destroy
    user = JsonWebToken.decode(request.headers['X-QA-Key'])
    if (user[:user_id] == @question[:user_id])
      if (@question.answers.count == 0)
        @question.destroy
        render json: {}
      else
        render json: {errors: "It has answers, it can't be deleted"}, status: :unprocessable_entity
      end
    else
      render json: { error: 'Not Authorized' }, status: 401
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def question_params
      params.require(:question).permit(:title, :description)
    end

    #Return if an user is authorized
    def authenticate_request
      @current_user = AuthorizeApiRequest.call(request.headers).result
      render json: { error: 'Not Authorized' }, status: 401 unless @current_user
    end
end
