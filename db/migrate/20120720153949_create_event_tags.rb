class CreateEventTags < ActiveRecord::Migration
  def change
    create_table :event_tags do |t|
      t.string :name
      t.text :description
      t.boolean :deleted

      t.timestamps
    end
  end
end
