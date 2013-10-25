class CreateEventDictionaryEventTags < ActiveRecord::Migration
  def change
    create_table :event_dictionary_event_tags do |t|
      t.integer :event_dictionary_id
      t.integer :event_tag_id

      t.timestamps
    end
  end
end
