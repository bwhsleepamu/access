class UpdateSourceType < ActiveRecord::Migration
  def change
    add_column :source_types, :file_pattern, :string
  end
end
