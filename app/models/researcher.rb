class Researcher < ActiveRecord::Base
  ##
  # Associations
  has_many :pi_subjects, :class_name => "Subject", :through => :subjects_pis, :source => :subject
  has_many :subjects_pis
  has_many :pl_subjects, :class_name => "Subject", :through => :subjects_project_leaders, :source => :subject
  has_many :subjects_project_leaders

  ##
  # Attributes
  # attr_accessible :email, :full_name, :first_name, :last_name, :notes

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
  #validates_uniqueness_of :email
  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :first_name, :scope => :last_name

  ##
  # Class Methods
  def self.split_full_name(full_name)
    # Splits either: First_Name Last_Name 
    #        or:     Last_Name, First_Name
    
    if full_name.index(",")
      split_name = full_name.split(",").map{|x| x.strip}
      {last_name: split_name.delete_at(0), first_name: split_name.join(" ")}
    else
      split_name = full_name.split(" ").map{|x| x.strip}
      {first_name: split_name.delete_at(0), last_name: split_name.join(" ")}
    end      
  end

  ##
  # Instance Methods

  def full_name
    "#{first_name} #{last_name}"
  end

  def update_subject_association(attrs)
    # Subject and Researcher must be in db already
    #MY_LOG.info "sa attrs: #{attrs}"
    subject = Subject.find(attrs[:subject_id])

    if attrs[:type] == :pi
      self.pi_subjects << subject unless self.pi_subjects.include? subject
    elsif attrs[:type] == :pl
      spl_attrs = {subject_id: subject.id, researcher_id: self.id, role: attrs[:role]}
      spl = SubjectsProjectLeader.where(spl_attrs)

      if spl.empty?
        spl = SubjectsProjectLeader.create(spl_attrs)
        #MY_LOG.info "CREATING: #{spl_attrs} #{spl.valid?} #{spl.errors.full_messages}"        
      end
      spl
    end

  end

  def full_name=(name)
    split_name = Researcher.split_full_name(name)

    self[:first_name] = split_name[:first_name]
    self[:last_name] = split_name[:last_name]
  end

  private
end
