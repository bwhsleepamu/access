class DocumentationsSupportingDocumentation < ActiveRecord::Base
  self.table_name = "supporting_documentations"

  belongs_to :parent, class_name: "Documentation", foreign_key: :parent_id
  belongs_to :child, class_name: "Documentation", foreign_key: :child_id
end
