class CreateEventDictionary < ActiveRecord::Migration
  def change
    create_table :event_dictionary do |t|
      t.string :name
      t.text :description
      t.boolean :deleted

      t.timestamps
    end
  end
end
