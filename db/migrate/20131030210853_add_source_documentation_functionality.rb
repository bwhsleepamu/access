class AddSourceDocumentationFunctionality < ActiveRecord::Migration
  def up
    add_column :documentations, :parent_id, :integer
    add_column :sources, :parent_id, :integer


    create_table :documentation_links do |t|
      t.integer :documentation_id
      t.integer :link_path
    end

    add_foreign_key :documentation_links, :documentations
    add_foreign_key(:sources, :sources, :column => 'parent_id', :dependent => :nullify)
    add_foreign_key(:documentations, :documentations, :column => 'parent_id', :dependent => :nullify)
    add_index :documentation_links, :documentation_id
    add_index :sources, :parent_id
    add_index :documentations, :parent_id

  end

  def down
    drop_table :documentation_links

    remove_column :documentations, :parent_id
    remove_column :sources, :parent_id
  end
end
