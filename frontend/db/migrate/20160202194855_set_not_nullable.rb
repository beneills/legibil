class SetNotNullable < ActiveRecord::Migration
  def change
    change_column_null :endpoints, :url,     false
    change_column_null :endpoints, :name,    false
    change_column_null :endpoints, :user_id, false

    change_column_null :users, :username,    false
  end
end
