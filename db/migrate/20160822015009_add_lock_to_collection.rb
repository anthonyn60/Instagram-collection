class AddLockToCollection < ActiveRecord::Migration[5.0]
  def change
  	add_column :collections, :locked, :boolean, default: false
  end
end
