class UsersController < ApplicationController
  include ErrorSerializer

  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = UserSerializer.new(User.all)
    render json: @users, status: :success
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      render json: UserSerializer.new(@user), status: :created
    else
      render json: ErrorSerializer.serialize(@user.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: ErrorSerializer.serialize(@user.errors), status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      begin  
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { :errors => [{:id => "user", :title => "User not found"}] }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:email, :password, :screen_name, :username)
    end
end
