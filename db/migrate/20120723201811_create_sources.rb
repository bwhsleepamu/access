class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.integer :source_type_id
      t.integer :user_id
      t.string :location
      t.text :description
      t.boolean :deleted

      t.timestamps
    end
  end
end
