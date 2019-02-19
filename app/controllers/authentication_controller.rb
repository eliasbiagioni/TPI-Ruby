class AuthenticationController < ApplicationController
 #skip_before_action :authenticate_request
 before_action :correct_content_type, only: [:authenticate]

 def authenticate
   command = AuthenticateUser.call(params[:email], params[:password])
   if command.success?
   	token = command.result
   	user = UserSerializer.new(User.find_by_email(params[:email]),{params: {token: command}})
    render json: user#{ auth_token: command.result }
   else
     render json: { error: command.errors }, status: :unauthorized
   end
 end

 #Return if content/type is application/json
 def correct_content_type
    render json: { error: 'Content-Type must be application/json' }, status: 406 unless request.content_type == 'application/json'
 end
end