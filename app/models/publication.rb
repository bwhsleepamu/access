class Publication < ActiveRecord::Base
  ##
  # Associations
  has_many :subjects, :through => :subjects_publications
  has_many :subjects_publications

  ##
  # Attributes
  # attr_accessible :authors, :endnote_id, :journal, :pubmed_id, :title, :year

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
  validates_uniqueness_of :endnote_id, :allow_nil => true, :allow_blank => true
  validates_uniqueness_of :pubmed_id, :allow_nil => true, :allow_blank => true

  ##
  # Class Methods
  def self.find_by_combo(attrs)
    finder_params = {}

    Publication.attribute_names.each do |a|
      #MY_LOG.info attrs[a.to_sym]
      finder_params[a.to_sym] = attrs[a.to_sym] if attrs[a.to_sym].present?
    end

    result = Publication.where(finder_params)
    #MY_LOG.info "r: #{result}\np: #{finder_params}\n\n"

    if result.length == 1
      result.first
    else
      nil
    end
  end

  ##
  # Instance Methods
  def name
    pubmed_id || end_note_id || title
  end

  private

end
