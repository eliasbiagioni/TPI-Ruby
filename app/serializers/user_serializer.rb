class UserSerializer
	include FastJsonapi::ObjectSerializer
	attributes :email, :username, :screen_name, :password
	has_many :questions
	has_many :answers

 	attribute :token do |user,params|
 		(params[:token]) ? params[:token].result : nil
	end
end
