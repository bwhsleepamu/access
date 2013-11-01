class DataDictionaryDataValue < ActiveRecord::Base
  #attr_accessible :data_dictionary_id, :data_value_id

  belongs_to :data_dictionary
  belongs_to :data_value
end
