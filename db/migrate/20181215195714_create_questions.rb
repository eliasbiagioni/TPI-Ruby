class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
		t.string :title, null: false, default: ""
		t.string :description, null: false, default: "" 
		t.boolean :status, null: false, default: false
      	t.timestamps
    end
  end
end
