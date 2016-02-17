class AddAttachmentPaletteToColourViews < ActiveRecord::Migration
  def self.up
    change_table :colour_views do |t|
      t.attachment :palette
    end
  end

  def self.down
    remove_attachment :colour_views, :palette
  end
end
