class CreateDataDataValues < ActiveRecord::Migration
  def change
    create_table :data_data_values do |t|
      t.integer :datum_id
      t.integer :data_value_id

      t.timestamps
    end
  end
end
