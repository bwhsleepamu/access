class FixPathInDocLink < ActiveRecord::Migration
  def up
    remove_column :documentation_links, :path
    add_column :documentation_links, :path, :string
  end

  def down
    remove_column :documentation_links, :path
    add_column :documentation_links, :path, :integer

  end
end
