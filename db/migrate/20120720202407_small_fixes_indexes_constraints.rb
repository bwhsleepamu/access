class SmallFixesIndexesConstraints < ActiveRecord::Migration
  def change
    remove_column :data_dictionary, :data_unit_id

    add_foreign_key :data_dictionary, :data_types
    add_foreign_key :data_dictionary, :data_values, :column => :min_value_id, :name => "data_dict_min_value_fk"
    add_foreign_key :data_dictionary, :data_values, :column => :max_value_id, :name => "data_dict_max_value_fk"
    add_index :data_dictionary, :min_value_id
    add_index :data_dictionary, :max_value_id
    add_index :data_dictionary, :data_type_id
    add_index :data_dictionary, :title

    add_foreign_key :data_dictionary_data_values, :data_dictionary
    add_foreign_key :data_dictionary_data_values, :data_values
    add_index :data_dictionary_data_values, [:data_dictionary_id, :data_value_id]
    add_index :data_dictionary_data_values, :data_value_id
    add_index :data_dictionary_data_values, :data_dictionary_id

    add_foreign_key :event_dictionary_data_fields, :event_dictionary
    add_foreign_key :event_dictionary_data_fields, :data_dictionary
    add_index :event_dictionary_data_fields, :event_dictionary_id
    add_index :event_dictionary_data_fields, :data_dictionary_id
    add_index :event_dictionary, :name

    add_foreign_key :event_dictionary_event_tags, :event_dictionary
    add_foreign_key :event_dictionary_event_tags, :event_tags
    add_index :event_dictionary_event_tags, :event_dictionary_id
    add_index :event_dictionary_event_tags, :event_tag_id
    add_index :event_tags, :name
  end

end
