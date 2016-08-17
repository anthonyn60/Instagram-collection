class ChangeTypeName < ActiveRecord::Migration[5.0]
  def change
  	remove_column :posts, :type
  	add_column :posts, :media_type, :text
  end
end
