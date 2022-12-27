class CreateTodos < ActiveRecord::Migration[5.2]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.boolean :status, default: false

      t.timestamps
    end
  end
end
