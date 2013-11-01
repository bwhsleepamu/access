class SubjectsProjectLeader < ActiveRecord::Base
  belongs_to :researcher
  belongs_to :subject

  # attr_accessible :notes, :role, :subject_id, :researcher_id

  validates_uniqueness_of :subject_id, :scope => [:role]
  validates_inclusion_of :role, :in => %w(original current), :allow_nil => true
end
