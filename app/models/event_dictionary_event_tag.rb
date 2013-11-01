class EventDictionaryEventTag < ActiveRecord::Base
  #attr_accessible :event_dictionary_id, :event_tag_id

  belongs_to :event_dictionary
  belongs_to :event_tag
end
