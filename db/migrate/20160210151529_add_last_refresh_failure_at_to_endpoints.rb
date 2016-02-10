class AddLastRefreshFailureAtToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :last_refresh_failure_at, :datetime
  end
end
