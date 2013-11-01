class DataQualityFlag < ActiveRecord::Base
  #attr_accessible :datum_id, :quality_flag_id

  belongs_to :datum
  belongs_to :quality_flag
end
