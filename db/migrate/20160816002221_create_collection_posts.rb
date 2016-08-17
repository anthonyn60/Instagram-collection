class CreateCollectionPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :collection_posts do |t|
      t.belongs_to :collection, index: true
      t.belongs_to :post, index: true
      t.integer :tag_time
      t.timestamps
    end
  end
end
