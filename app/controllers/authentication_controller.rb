class AuthenticationController < ApplicationController
 #skip_before_action :authenticate_request

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
end