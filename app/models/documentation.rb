class Documentation < ActiveRecord::Base
  ##
  # Associations
  has_many :data
  has_many :events
  has_many :change_logs
  belongs_to :user
  has_many :documentation_links, dependent: :destroy, autosave: true

  has_many :supporting_documentations, through: :documentations_supporting_documentations, source: :child, foreign_key: :parent_id
  has_many :supported_documentations, through: :documentations_supported_documentations, source: :parent, foreign_key: :child_id

  has_many :documentations_supporting_documentations, foreign_key: :parent_id
  has_many :documentations_supported_documentations, foreign_key: :child_id, class_name: "DocumentationsSupportingDocumentation"

  ##
  # Attributes
  #attr_accessible :author, :description_of_procedure, :origin_location, :title, :user_id
  accepts_nested_attributes_for :documentation_links, allow_destroy: true



  ##
  # Callbacks

  ##
  # Concerns
  include Loggable, Associatable, Indexable, Deletable

  ##
  # Database Settings

  ##
  # Scopes
  scope :search, lambda { |term| search_scope([:title, :author, :description], term) }

  ##
  # Validations
  validates_presence_of :title, :author, :description, :user_id

  ##
  # Class Methods
  def documentation_user=(user_params)
    set_immutable(User, user_params)
  end

  ##
  # Instance Methods

  private

end
