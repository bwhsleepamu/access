class DataType < ActiveRecord::Base
  ##
  # Associations
  has_many :data_dictionary

  ##
  # Attributes
  # attr_accessible :length, :multiple, :name, :range, :storage, :values

  ##
  # Callbacks

  ##
  # Concerns
  include Loggable, Deletable

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
