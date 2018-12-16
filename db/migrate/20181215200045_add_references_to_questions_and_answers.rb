class AddReferencesToQuestionsAndAnswers < ActiveRecord::Migration[5.2]
  def change
  	add_reference :questions, :user, foreign_key: true
  	add_reference :questions, :answer, foreign_key: true, null: true
  	add_reference :answers, :question, foreign_key: true
  	add_reference :answers, :user, foreign_key: true
  end
end
