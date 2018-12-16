class Answer < ApplicationRecord
	#Answer assosiations
	belongs_to :user
	belongs_to :question

	#Validations
	validates_presence_of :content, :question_id, :user_id
end
