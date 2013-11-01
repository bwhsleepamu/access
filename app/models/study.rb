class Study < ActiveRecord::Base
  ##
  # Associations
  has_many :subjects
  has_many :study_nicknames, -> { current }, dependent: :destroy

  ##
  # Attributes
  # attr_accessible :description, :official_name, :nicknames

  ##
  # Concerns
  include Loggable, Deletable, Indexable

  ##
  # Database Settings

  ##
  # Scopes
  scope :search, lambda { |term| search_scope([:official_name, :description, {join: :study_nicknames, column: :nickname }], term) }

  ##
  # Validations
  validates_uniqueness_of :official_name
  validates_presence_of :official_name

  ##
  # Class Methods

  ##
  # Instance Methods
  def nicknames=(nickname_array)
    #study_nicknames.each {|sn| sn.destroy}
    if nickname_array.class == String
      nickname_array = nickname_array.split(";").map{|x| x.strip}
    end

    study_nicknames.clear
    nickname_array.each {|nickname| study_nicknames.build(nickname: nickname)}
  end

  private

end
