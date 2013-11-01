class SubjectsPi < ActiveRecord::Base
  belongs_to :researcher
  belongs_to :subject

  # attr_accessible :researcher_id, :subject_id

  validates_uniqueness_of :researcher_id, :scope => :subject_id
end
