class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email, :username, :screen_name, :password
  has_many :questions
  has_many :answers
end
