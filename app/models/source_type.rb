=begin
TODO:

Finish Documentation:
  - Standard Location
  - Link to more documentation
  - Format description

Events.dbf
Markers.dbf
New Forms.dbf

=end

class SourceType < ActiveRecord::Base
  ##
  # Associations
  has_many :sources

  ##
  # Attributes
  # attr_accessible :description, :name

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
