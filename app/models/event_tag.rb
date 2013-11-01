class EventTag < ActiveRecord::Base
  ##
  # Associations
  has_many :event_dictionary, :through => :event_dictionary_event_tags
  has_many :event_dictionary_event_tags

  ##
  # Attributes
  # attr_accessible :description, :name

  ##
  # Callbacks

  ##
  # Concerns
  include Loggable

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
