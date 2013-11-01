class Datum < ActiveRecord::Base
  ##
  # Associations
  has_many :data_values, :autosave => true
  has_many :quality_flags, :through => :data_quality_flags
  has_many :data_quality_flags
  belongs_to :documentation
  belongs_to :source
  belongs_to :event
  #belongs_to :data_dictionary, :foreign_key => :title, :primary_key => :title


  ##
  # Attributes
  #attr_accessible :documentation_id, :notes, :source_id, :title, :value, :values, :event_id

  ##
  # Callbacks

  ##
  # Database Settings
  self.sequence_name =  "object_id_seq"

  ##
  # Concerns
  include Loggable, Associatable, Deletable

  ##
  # Scopes

  ##
  # Validations
  validates_presence_of :title

  ##
  # Class Methods
  #def self.build_from_dictionary(title)
  #  dd = DataDictionary.find_by_title(title)
  #  qf = QualityFlag.find_by_name("uninitialized")
  #
  #  raise StandardError, "Cannot build datum. Data Dictionary record with title #{title} not found." if dd.blank?
  #  raise StandardError, "Cannot build datum. Quality flag missing" if qf.blank?
  #
  #  d = self.new(title: title)
  #  d.quality_flags << qf
  #  d
  #end

  ##
  # Instance Methods
  def data_dictionary=(dd)
    self[:title] = dd.title
  end

  def data_dictionary
    DataDictionary.find_by_title(title)
  end

  def value=(val)
    #MY_LOG.info "SETTING VALUE #{val}"
    # For single values
    raise StandardError, "Cannot set value. Data Dictionary not set for Datum" unless data_dictionary

    if data_dictionary.multivalue?
      #MY_LOG.info "MULTI"
      self.values = [val]
    elsif data_values.length == 1
      #MY_LOG.info "EXISTS"
      # Data Value Exists already
      data_values.first.value = val
    else
      #MY_LOG.info "NEW"
      # Data Value does not exist
      add_new_data_value(val)
    end

    #MY_LOG.info "SET VALUE: #{value}"
  end

  def value
    raise StandardError, "Cannot get value. Data Dictionary not set for Datum" unless data_dictionary
    raise StandardError, "Multiple values found. This function supports single value Data only" if data_values.length > 1

    #MY_LOG.info "GETTING VALUE (#{data_values.length})"
    if data_values.length == 1
      data_values.first.value
    else
      nil
    end
  end


  def values=(vals)
    raise StandardError, "Cannot set values. Data Dictionary not set for Datum" unless data_dictionary
    raise StandardError, "Cannot set values. Must be called with an array of values" unless vals.kind_of?(Array)
    raise StandardError, "Cannot set values. Multiple values not allowed for this kind of data #{data_dictionary.title} #{data_dictionary.multivalue}. Please use value=" unless data_dictionary.multivalue?

    data_values.clear

    #MY_LOG.info "BEFORE: #{data_data_values.length} #{data_data_values}"

    vals.each do |val|
      add_new_data_value(val)
    end

    #MY_LOG.info "AFTER: #{data_data_values.length} #{data_data_values}"
  end

  def values
    data_values.map{ |dv| dv.value }
  end

  def quality_flag_list=(quality_flag_hash)
    set_list(DataQualityFlag, QualityFlag, quality_flag_hash)
  end

  def datum_source=(source_params)
    set_associated(Source, source_params)
  end

  def datum_documentation=(documentation_params)
    set_associated(Documentation, documentation_params)
  end

  def data_type
    if data_dictionary
      data_dictionary.data_type
    else
      nil
    end
  end

  private

  def add_new_data_value(val)
    #MY_LOG.info "val: #{val}"
    data_value = DataValue.new()

    data_value.datum = self
    data_value.value = val
    data_values << data_value


    #assoc = DataDataValue.new()
    #assoc.data_value = data_value
    #assoc.datum = self

    #data_data_values << assoc
    #data_value.data_data_values << assoc

#    data_values << data_value
#    data_value.data << self
#
#    data_value.value = val
#
##    data_value.save unless self.id.blank?
#
#    MY_LOG.info "data value: #{data_value} #{data_value.valid?}"

  end

  def destroy_children
    data_values.each do |dv|
      dv.destroy
    end
  end
end
