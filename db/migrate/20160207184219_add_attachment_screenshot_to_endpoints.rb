class AddAttachmentScreenshotToEndpoints < ActiveRecord::Migration
  def self.up
    change_table :endpoints do |t|
      t.attachment :screenshot
    end
  end

  def self.down
    remove_attachment :endpoints, :screenshot
  end
end
