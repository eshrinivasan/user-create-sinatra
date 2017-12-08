class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      # ":first_name" and ":last_name" symbols create
      # "first_name" and "last_name" column names
      t.string :first_name
      t.string :last_name
      # The line below creates "created_at" and "updated_at"
      # columns that are filled with the appropriate times
      t.timestamps null: false
    end
  end
end
