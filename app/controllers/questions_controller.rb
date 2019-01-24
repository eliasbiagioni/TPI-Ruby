class QuestionsController < ApplicationController
  include ErrorSerializer

  before_action :set_question, only: [:show, :update, :destroy, :resolve, :questions_answers, :new_answer, :delete_answer]
  before_action :authenticate_request, only: [:create, :update, :destroy, :resolve, :new_answer, :delete_answer]
  before_action :question_belongs_to_current_user, only: [:resolve]
  before_action :set_answer, only: [:delete_answer]
  attr_reader :current_user

  # GET /questions
  def index
    case params[:sort]
      when "pending_first"
        @questions = QuestionSerializer.new(Question.order(status: :asc).limit(50))
      when "needing_help"
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
      render json: QuestionSerializer.new(@question, {params: {complete: true}}), status: :created, location: @question
    else
      render json: ErrorSerializer.serialize(@question.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /questions/1
  def update
    user = JsonWebToken.decode(request.headers['X-QA-Key'])
    if (user[:user_id] == @question[:user_id])
      if @question.update(question_params)
        render json: QuestionSerializer.new(@question)
      else
        render json: ErrorSerializer.serialize(@question.errors), status: :unprocessable_entity
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
        render json: {errors: "It has answers, it can't be deleted"}, status: :forbidden
      end
    else
      render json: { error: 'Not Authorized' }, status: 401
    end
  end

  #PUT /questions/:id/resolve  
  def resolve
    if answer_belongs_to_question
      @question.status = true
      @question.answer_id = params[:question][:answer_id]
      @question.save
      render json: QuestionSerializer.new(@question, {params: {resolve: true}})
    else
      render json: { :errors => [{:id => "question_answers", :title => "Answer doesn't belongs to the question"}] }, status: :forbidden
    end
  end

  #GET /questions/:question_id/answers
  def questions_answers
    render json: AnswerSerializer.new(@question.answers)
  end

  #POST /questions/:question_id/answers
  def new_answer
    if @question.status
      render json: { :errors => [{:id => "question", :title => "Question is solved"}] }, status: :unprocessable_entity
    else  
      param = {}
      param[:content] = params[:content]
      param[:question_id] = @question.id
      param[:user_id] = @current_user.id 
      q = Answer.create(param)
      (q.save) ? (render json: AnswerSerializer.new(q), status: :created) : (render json: ErrorSerializer.serialize(q.errors), status: :unprocessable_entity)
    end
  end

  #DELETE /questions/:question_id/answers/:id
  def delete_answer
    if @question.status 
      render json: { :errors => [{:id => "question", :title => "Question is solved"}] }, status: :forbidden
    else
      #puts "ANSWER USER ID: #{@answer.user_id} CURRENT USER ID: #{@current_user.id}"
      if @answer.user_id != @current_user.id
        render json: { :errors => [{:id => "user", :title => "Not authorized to delete the answer"}] }, status: :unauthorized
      else
        if !@question.answers.include?(@answer)
          render json: { :errors => [{:id => "question", :title => "The answer doesn't belong to that question"}] }, status: :forbidden
        else
          @answer.destroy
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      begin
        (params[:id].nil?) ? @question = Question.find(params[:question_id]) : @question = Question.find(params[:id]) 
      rescue ActiveRecord::RecordNotFound
        render json: { :errors => [{:id => "question", :title => "Question not found"}] }, status: :not_found
      end
    end

    def set_answer
      begin
        @answer = Answer.find(params[:answer_id]) 
      rescue ActiveRecord::RecordNotFound
        render json: { :errors => [{:id => "answer", :title => "Answer not found"}] }
      end
    end

    # Only allow a trusted parameter "white list" through. CREATED_AT and STATUS are permitted for testing only.
    def question_params
      params.require(:question).permit(:title, :description, :created_at, :status)
    end

    #Return if an user is authorized
    def authenticate_request
      puts "Entra"
      @current_user = AuthorizeApiRequest.call(request.headers).result
      render json: { error: 'Not Authorized' }, status: 401 unless @current_user
    end

    #Return if an answer belongs to the question passed as argument
    def answer_belongs_to_question
      #puts "ESTO IMPRIME #{params[:question][:answer_id]}"
      (@question.answers.include?(Answer.find(params[:question][:answer_id])))
    end

    #Return if the question belongs to the current user
    def question_belongs_to_current_user
      (@current_user.id.equal?(@question.user_id)) ? true : (render json: { :errors => [{:id => "question_owner", :title => "Question doesn't belongs to the user that is logged in"}] }, status: :unauthorized)
    end
end
