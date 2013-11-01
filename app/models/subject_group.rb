class SubjectGroup < ActiveRecord::Base
  ##
  # Associations
  has_many :subjects, :through => :subjects_subject_groups
  has_many :subjects_subject_groups

  ##
  # Attributes
  # attr_accessible :description, :name, :subject_ids

  ##
  # Callbacks

  ##
  # Concerns
  include Loggable, Indexable, Deletable

  ##
  # Database Settings

  ##
  # Scopes
  scope :search, lambda { |term| search_scope([:name, :description], term) }

  ##
  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name

  ##
  # Class Methods

  ##
  # Instance Methods
end
