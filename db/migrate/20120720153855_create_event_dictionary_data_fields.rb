class CreateEventDictionaryDataFields < ActiveRecord::Migration
  def change
    create_table :event_dictionary_data_fields do |t|
      t.integer :event_dictionary_id
      t.integer :data_dictionary_id

      t.timestamps
    end
  end
end
