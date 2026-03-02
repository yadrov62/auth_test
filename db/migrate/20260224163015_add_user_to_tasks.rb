class AddUserToTasks < ActiveRecord::Migration[7.2]
  def change
    add_reference :tasks, :user, foreign_key: true

    reversible do |dir|
      dir.up do
        # Assign existing tasks to a default user (e.g., the first user)
        default_user_id = User.first&.id
        if default_user_id
          Task.update_all(user_id: default_user_id)
        else
          raise "No users found. Please create a user before running this migration."
        end
      end
    end

    change_column_null :tasks, :user_id, false
  end
end
