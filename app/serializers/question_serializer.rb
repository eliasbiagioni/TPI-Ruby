class QuestionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :title, :status
  has_many :answers, if: Proc.new{ |question, params| params[:complete] == true } 
  belongs_to :user, if: Proc.new{ |question, params| params[:complete] == true }
  
  attribute :number_of_answers do |question|
  	question.answers.count	
  end

  attribute :description do |question|
  	(question.description.length) > 120 ? question.description[0..120].concat("...") : question.description
  end

end
