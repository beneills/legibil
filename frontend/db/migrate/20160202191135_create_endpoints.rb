class CreateEndpoints < ActiveRecord::Migration
  def change
    create_table :endpoints do |t|
      t.text :url
      t.string :name, limit: 30
      t.reference :user

      t.timestamps null: false
    end
  end
end
