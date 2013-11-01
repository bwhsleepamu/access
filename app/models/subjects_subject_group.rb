class SubjectsSubjectGroup < ActiveRecord::Base
  # attr_accessible :subject_id, :subject_group_id

  belongs_to :subject
  belongs_to :subject_group

  validates_uniqueness_of :subject_id, :scope => :subject_group_id
end
