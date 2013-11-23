class DocumentationLink < ActiveRecord::Base
  belongs_to :documentation

  validates_presence_of :link_path
end