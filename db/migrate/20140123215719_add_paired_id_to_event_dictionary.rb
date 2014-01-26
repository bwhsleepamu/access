class AddPairedIdToEventDictionary < ActiveRecord::Migration
  def change
    add_column :event_dictionary, :paired_id, :integer
    add_foreign_key :event_dictionary, :event_dictionary, column: 'paired_id', dependent: :nullify
  end
end
