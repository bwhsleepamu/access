class QualityFlag < ActiveRecord::Base
  ##
  # Associations
  has_many :events, :through => :event_quality_flags
  has_many :event_quality_flags
  has_many :data, :through => :data_quality_flags
  has_many :data_quality_flags

  ##
  # Attributes
  # attr_accessible :description, :name

  ##
  # Callbacks

  ##
  # Concerns
  include Loggable, Deletable

  ##
  # Database Settings

  ##
  # Scopes

  ##
  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name

  ##
  # Class Methods

  ##
  # Instance Methods

  private
end
