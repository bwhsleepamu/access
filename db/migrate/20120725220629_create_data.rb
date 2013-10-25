class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.string :title
      t.text :notes
      t.integer :source_id
      t.integer :documentation_id
      t.boolean :deleted

      t.timestamps
    end
  end
end
