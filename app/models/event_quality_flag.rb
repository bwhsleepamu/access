class EventQualityFlag < ActiveRecord::Base
  belongs_to :event
  belongs_to :quality_flag

  #attr_accessible :event_id, :quality_flag_id
end
