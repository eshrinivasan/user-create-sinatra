class CreateTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :todos do |t|
      t.belongs_to :username
      t.string :user_name, null:false
      t.string :content, null: false
      t.integer :points, default: 0
      t.string :flag, default: 'like'
      t.string :team
      t.timestamps
    end
  end
end
