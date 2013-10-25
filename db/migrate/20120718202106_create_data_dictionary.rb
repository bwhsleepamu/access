class CreateDataDictionary < ActiveRecord::Migration
  def change
    create_table :data_dictionary do |t|
      t.string :title
      t.text :description
      t.integer :data_type_id
      t.integer :data_unit_id
      t.integer :min_value_id
      t.boolean :min_value_inclusive
      t.integer :max_value_id
      t.boolean :max_value_inclusive
      t.boolean :multivalue
      t.integer :min_length
      t.string :max_length_integer
      t.string :unit
      t.boolean :deleted

      t.timestamps
    end
  end
end
