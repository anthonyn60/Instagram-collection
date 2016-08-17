class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.string :tag
      t.string :name
      t.integer :start_time
      t.integer :end_time
      t.string :next_url
      t.timestamps
    end
  end
end
