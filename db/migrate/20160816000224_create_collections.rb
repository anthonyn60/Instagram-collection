class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.string :tag
      t.integer :start
      t.integer :end
      t.timestamps
    end
  end
end
