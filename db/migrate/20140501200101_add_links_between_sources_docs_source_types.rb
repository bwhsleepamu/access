class AddLinksBetweenSourcesDocsSourceTypes < ActiveRecord::Migration
  def change
    add_column :source_types, :documentation_id, :integer
    add_column :sources, :documentation_id, :integer

    add_foreign_key(:source_types, :documentations, dependent: :nullify)
    add_foreign_key(:sources, :documentations, dependent: :nullify)

    add_index :sources, :documentation_id
    add_index :source_types, :documentation_id
  end
end
