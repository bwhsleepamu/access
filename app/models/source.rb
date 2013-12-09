class Source < ActiveRecord::Base
  ##
  # Associations
  has_many :data
  has_many :events
  has_many :change_logs
  belongs_to :source_type
  belongs_to :user
  has_many :child_sources, class_name: "Source", foreign_key: "parent_id", autosave: true
  belongs_to :parent_source, class_name: "Source", foreign_key: "parent_id"

  ##
  # Attributes
  # attr_accessible :description, :location, :source_type_id, :user_id, :notes

  ##
  # Callbacks

  ##
  # Concerns
  include Loggable, Indexable, Associatable, Deletable

  ##
  # Database Settings

  ##
  # Scopes
  scope :search, lambda { |term| search_scope([:id, :location, :original_location, :description, :notes], term) }

  ##
  # Validations
  validates_presence_of :location

  ##
  # Class Methods

  ##
  # Instance Methods
  def type=(type_params)
    set_immutable(SourceType, type_params)
  end

  def source_user=(user_params)
    set_immutable(User, user_params)
  end


  private


end
