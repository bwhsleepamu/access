class DataValue < ActiveRecord::Base
  ##
  # Associations
  has_many :data_dictionary_as_allowed_value, :through => :data_dictionary_data_value, :source => :data_dictionary, :class_name => "DataDictionary"
  has_one :data_dictionary_data_value
  belongs_to :datum
  has_one :data_dictionary_as_min_value, :class_name => "DataDictionary", :foreign_key => :min_value_id
  has_one :data_dictionary_as_max_value, :class_name => "DataDictionary", :foreign_key => :max_value_id

  ##
  # Attributes
  # attr_accessible :value, :type_flag, :datum_id, :datum

  ##
  # Callbacks
  before_validation :set_type_flag

  ##
  # Concerns
  include Loggable, Deletable

  ##
  # Constants
  VALUE_FIELDS = %w(text_value num_value time_value)

  ##
  # Scopes

  ##
  # Validations
  validates_presence_of :type_flag
  validates_inclusion_of :type_flag, :in => VALUE_FIELDS

  ##
  # Class Methods

  ##
  # Instance Methods
  def value=(val)
    set_type_flag
    val = validate_value_type(val)

    if type_flag
      self[type_flag] = val
      #MY_LOG.info "AFTER: #{type_flag} #{self[type_flag]}"
    else
      raise StandardError, "No type flag set for Data Value."
    end
  end

  def value
    self[type_flag]
  end

  def data_type
    # error if too many associations of one type
    # error if more than one type of association
    possible_associations = [data_dictionary_as_allowed_value, datum, data_dictionary_as_min_value, data_dictionary_as_max_value]
    associated_count = 0
    my_association = nil
    possible_associations.each do |association|
      if association
        if association.respond_to? :each
          if association.length > 0
            associated_count += 1
            my_association = association.first
          end
          raise StandardError, "Data Value only allowed to belong to one association.\n#{association}\n#{association.length}" if association.length > 1
        else
          associated_count += 1
          my_association = association
        end
      end
    end
    raise StandardError, "Data Value only allowed to belong to one association.\n#{possible_associations}\n#{associated_count}" if associated_count > 1

    my_association ? my_association.data_type : nil
  end

  def force_type!(data_type)
    self[:type_flag] = data_type.storage
  end


  private


  def set_type_flag
    self[:type_flag] = data_type.storage if data_type and self[:type_flag].nil?
  end

  def numeric?(val)
    return true if val =~ /^\d+$/
    true if Float(val) rescue false
  end

  def validate_value_type(val)
    # Validate numeric strings for now
    if type_flag == "num_value" and val.kind_of? String and !numeric?(val)
      nil
    else
      val
    end
  end

end
