class DataDictionary < ActiveRecord::Base
  ##
  # Associations
  belongs_to :min_data_value, :class_name => "DataValue", :foreign_key => :min_value_id, :autosave => true
  belongs_to :max_data_value, :class_name => "DataValue", :foreign_key => :max_value_id, :autosave => true
  has_many :allowed_data_values, :class_name => "DataValue", :through => :data_dictionary_data_values, :source => :data_value, :autosave => true
  has_many :data_dictionary_data_values
  has_many :event_dictionary, :through => :event_dictionary_data_fields
  has_many :event_dictionary_data_fields
  belongs_to :data_type
  #has_many :data, :foreign_key => :title, :primary_key => :title

  ##
  # Attributes
  #attr_accessible :data_type_id, :description, :max_length, :max_value, :max_value_inclusive, :min_length, :min_value, :min_value_inclusive, :multivalue, :title, :unit, :allowed_values

  ##
  # Callbacks

  ##
  # Concerns
  include Indexable, Loggable, Deletable

  ##
  # Scopes
  scope :search, lambda { |term| search_scope([:title, :description, :unit], term) }

  ##
  # Validations
  validates_presence_of :title
  validates_uniqueness_of :title

  ##
  # Class Methods

  ##
  # Instance Methods

  def allowed_values=(val_array)
    allowed_data_values.clear

    val_array.each do |val|
      if val.present?
        dv = allowed_data_values.build
        dv.force_type!(self.data_type)
        dv.value = val
      end
    end
  end

  def allowed_values
    allowed_values? ? allowed_data_values.collect {|dv| dv.value} : nil
  end

  def max_value=(val)
    if max_data_value.present?
      max_data_value.value = val
    else
      mv = build_max_data_value
      mv.data_dictionary_as_max_value = self
      mv.value = val
    end
  end

  def min_value=(val)
    if min_data_value
      min_data_value.value = val
    else
      mv = build_min_data_value
      mv.data_dictionary_as_min_value = self
      mv.value = val
    end
  end

  def max_value
    max_value? ? max_data_value.value : nil
  end

  def min_value
    min_value? ? min_data_value.value : nil
  end

  def min_value?
    data_type && data_type.range? && !min_data_value.nil?
  end

  def max_value?
    data_type && data_type.range? && !max_data_value.nil?
  end

  def allowed_values?
    data_type && data_type.values? && !allowed_data_values.empty? && !allowed_data_values.nil?
  end

  def min_length?
    !min_length.nil? && data_types.length?
  end

  def max_length?
    !max_length.nil? && data_types.length?
  end

  private

end
