class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :type
      t.string :insta_link
      t.string :insta_id
      t.string :media
      t.string :username
      t.string :caption
      t.timestamps
    end
  end
end
