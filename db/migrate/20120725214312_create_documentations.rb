class CreateDocumentations < ActiveRecord::Migration
  def change
    create_table :documentations do |t|
      t.string :title
      t.string :author
      t.string :origin_location
      t.text :description_of_procedure
      t.integer :user_id
      t.boolean :deleted

      t.timestamps
    end
  end
end
