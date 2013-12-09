module ETL
  SAVED_OBJECT_DIR = "lib/data/etl/SAVED_OBJECTS"

  require 'etl/helpers/helpers'

  # Extract
  require 'etl/extract/dbf_reader'
  require 'etl/extract/t_drive_crawler'

  # Transform
  require 'etl/transform/actigraphy_merger'
  require 'etl/transform/dbf_file_merger'
  require 'etl/transform/psq_merger'

  # Load
  require 'etl/load/database_loader'
  require 'etl/load/sleep_stage_loader'
  require 'etl/load/subject_information_loader'
  require 'etl/load/subject_demographics_loader'
  require 'etl/load/actigraphy_loader'
  require 'etl/load/fd_nosa_information_loader'
  require 'etl/load/dbf_loader'
  require 'etl/load/new_forms_loader'
  require 'etl/load/psq_loader'
end
