class EventDictionaryDataField < ActiveRecord::Base
  #attr_accessible :data_dictionary_id, :event_dictionary_id

  belongs_to :event_dictionary
  belongs_to :data_dictionary
end
