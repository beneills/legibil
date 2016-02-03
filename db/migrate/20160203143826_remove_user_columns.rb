class RemoveUserColumns < ActiveRecord::Migration
  def change
    remove_column :users, :username
    remove_column :users, :password_digest
  end
end
