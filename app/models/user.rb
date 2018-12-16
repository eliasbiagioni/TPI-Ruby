class User < ApplicationRecord
	has_secure_password
    #User assosiations
    has_many :questions
    has_many :answers


    #User validations
   	validates_presence_of :username, :email, :screen_name, :password
   	validates_format_of :email, :with =>/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i    	
    validates_uniqueness_of :username
end
