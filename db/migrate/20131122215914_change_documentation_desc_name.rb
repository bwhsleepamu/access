class ChangeDocumentationDescName < ActiveRecord::Migration
  def change
    rename_column :documentations, :description_of_procedure, :description
  end
end
