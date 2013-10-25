class CreateDataDictionaryDataValues < ActiveRecord::Migration
  def change
    create_table :data_dictionary_data_values do |t|
      t.integer :data_dictionary_id
      t.integer :data_value_id

      t.timestamps
    end
  end
end
