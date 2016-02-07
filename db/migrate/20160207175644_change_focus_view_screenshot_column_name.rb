class ChangeFocusViewScreenshotColumnName < ActiveRecord::Migration
  def self.up
    remove_attachment :focus_views, :screenshot

    change_table :focus_views do |t|
      t.attachment :focus_area
    end
  end

  def self.down
    remove_attachment :focus_views, :focus_area

    change_table :focus_views do |t|
      t.attachment :screenshot
    end
  end
end
