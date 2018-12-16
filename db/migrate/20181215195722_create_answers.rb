class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
		t.string :content, null: false, default: ""
    	t.timestamps
    end
  end
end
