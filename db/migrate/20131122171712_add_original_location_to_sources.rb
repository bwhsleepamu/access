class AddOriginalLocationToSources < ActiveRecord::Migration
  def change
    add_column :sources, :original_location, :string
  end
end
