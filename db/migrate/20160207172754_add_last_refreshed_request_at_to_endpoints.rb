class AddLastRefreshedRequestAtToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :last_refresh_request_at, :datetime
  end
end
