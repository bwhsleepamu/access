class EventDictionary < ActiveRecord::Base
  ##
  # Associations
  has_many :event_tags, :through => :event_dictionary_event_tags
  has_many :event_dictionary_event_tags
  has_many :data_dictionary, :through => :event_dictionary_data_fields
  has_many :event_dictionary_data_fields
  has_many :events, :foreign_key => :name, :primary_key => :name

  ##
  # Attributes
  #attr_accessible :description, :name, :data_dictionary_ids, :event_tag_ids

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

  private
end
