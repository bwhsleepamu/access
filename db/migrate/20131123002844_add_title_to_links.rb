class AddTitleToLinks < ActiveRecord::Migration
  def change
    add_column :documentation_links, :title, :string
    rename_column :documentation_links, :link_path, :path
  end
end
