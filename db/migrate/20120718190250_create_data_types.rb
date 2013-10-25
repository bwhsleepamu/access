class CreateDataTypes < ActiveRecord::Migration
  def change
    create_table :data_types do |t|
      t.string :name
      t.string :storage
      t.boolean :range
      t.boolean :length
      t.boolean :values
      t.boolean :multiple
      t.boolean :deleted

      t.timestamps
    end
  end
end
