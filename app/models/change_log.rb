class ChangeLog < ActiveRecord::Base
  ##
  # Associations
  belongs_to :source
  belongs_to :documentation
  belongs_to :user

  ##
  # Attributes
  #attr_accessible :model_id, :source_id, :documentation_id, :timestamp, :action_type, :user_id

  ##
  # Callbacks

  ##
  # Database Settings

  ##
  # Scopes
  scope :recent, lambda {|model_id| where(model_id: model_id).order("timestamp DESC") }
  scope :with_source, -> { where("source_id is not null") }
  scope :with_documentation, -> { where("documentation_id is not null") }

  ## TESTED
  ## UNTESTED

  ##
  # Validations

  ##
  # Class Methods

  ## TESTED

  ## UNTESTED

  ##
  # Instance Methods

  ## TESTED

  ## UNTESTED

  private


end