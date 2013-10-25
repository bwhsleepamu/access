class AddNotesToSource < ActiveRecord::Migration
  def change
    add_column :sources, :notes, :text
  end
end
