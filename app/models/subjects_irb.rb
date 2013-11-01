class SubjectsIrb < ActiveRecord::Base
  belongs_to :irb
  belongs_to :subject

  # attr_accessible :irb_id, :subject_id

  validates_uniqueness_of :irb_id, :scope => :subject_id
end
