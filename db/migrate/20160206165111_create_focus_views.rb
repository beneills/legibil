class CreateFocusViews < ActiveRecord::Migration
  def change
    create_table :focus_views do |t|
      t.references :endpoint, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
