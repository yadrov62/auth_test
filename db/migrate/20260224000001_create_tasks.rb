class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.boolean :completed, default: false, null: false

      t.timestamps
    end

    add_index :tasks, :completed
    add_index :tasks, :created_at
  end
end

