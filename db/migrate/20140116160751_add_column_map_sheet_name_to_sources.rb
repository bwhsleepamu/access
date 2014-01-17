class AddColumnMapSheetNameToSources < ActiveRecord::Migration
  def change
    add_column :sources, :column_map, :text
    add_column :sources, :worksheet_name, :string
  end
end
