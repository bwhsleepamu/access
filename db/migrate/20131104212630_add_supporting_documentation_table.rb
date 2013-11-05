class AddSupportingDocumentationTable < ActiveRecord::Migration
  def up
    remove_column :documentations, :parent_id

    create_table :supporting_documentations do |t|
      t.integer :parent_id
      t.integer :child_id
    end

    add_index :supporting_documentations, :child_id
    add_index :supporting_documentations, :parent_id

    add_foreign_key(:supporting_documentations, :documentations, :column => 'parent_id')
    add_foreign_key(:supporting_documentations, :documentations, :column => 'child_id')

  end

  def down
    drop_table :supporting_documentations

    add_column :documentations, :parent_id, :integer
  end
end
