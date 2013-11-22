class Documentation < ActiveRecord::Base
  ##
  # Associations
  has_many :data
  has_many :events
  has_many :change_logs
  belongs_to :user
  has_many :supporting_documentations, foreign_key:

  ##
  # Attributes
  #attr_accessible :author, :description_of_procedure, :origin_location, :title, :user_id

  ##
  # Callbacks

  ##
  # Concerns
  include Loggable, Associatable, Indexable, Deletable

  ##
  # Database Settings

  ##
  # Scopes
  scope :search, lambda { |term| search_scope([:title, :author, :origin_location, :description_of_procedure], term) }

  ##
  # Validations
  validates_presence_of :title, :author, :description_of_procedure, :user_id

  ##
  # Class Methods
  def documentation_user=(user_params)
    set_immutable(User, user_params)
  end

  ##
  # Instance Methods

  private

end
