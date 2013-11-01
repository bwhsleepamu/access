class SubjectsPublication < ActiveRecord::Base
  belongs_to :publication
  belongs_to :subject

  # attr_accessible :publication_id, :subject_id

  validates_uniqueness_of :publication_id, :scope => :subject_id
end
