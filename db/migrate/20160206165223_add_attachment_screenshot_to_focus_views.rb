class AddAttachmentScreenshotToFocusViews < ActiveRecord::Migration
  def self.up
    change_table :focus_views do |t|
      t.attachment :screenshot
    end
  end

  def self.down
    remove_attachment :focus_views, :screenshot
  end
end
