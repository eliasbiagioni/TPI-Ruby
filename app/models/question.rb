class Question < ApplicationRecord
	#Question assosiations
	belongs_to :user
	has_many :answers

	#Validations
	validates_presence_of :title, :description, :user_id
end
