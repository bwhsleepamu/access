class StudyNickname < ActiveRecord::Base
  ##
  # Associations
  belongs_to :study

  ##
  # Attributes
  # attr_accessible :nickname, :study_id

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
  validates_presence_of :nickname

  ##
  # Class Methods

  ##
  # Instance Methods

  private
end
