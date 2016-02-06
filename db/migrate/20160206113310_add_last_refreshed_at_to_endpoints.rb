class AddLastRefreshedAtToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :last_refreshed_at, :datetime
  end
end
