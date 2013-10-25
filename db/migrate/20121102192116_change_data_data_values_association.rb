class ChangeDataDataValuesAssociation < ActiveRecord::Migration
  def up
    drop_table :data_data_values
    add_column :data_values, :datum_id, :integer
    add_index :data_values, :datum_id
  end

  def down
    remove_index :data_values, :datum_id
    remove_column :data_values, :datum_id

    create_table :data_data_values do |t|
      t.integer :datum_id
      t.integer :data_value_id
    end
  end
end
