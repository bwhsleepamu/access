module ETL
  class NewFormsLoader
    MERGED_FILE_PREFIX = "NewForms_"
    NEW_FORMS_COLUMNS = ["LABTIME", "SECONDS", "EVENTDESC", "EVENTCODE"]
    DBF_LOADER_CONFIG = {
        conditional_columns: [2, 3],
        static_params: {},
        event_groups: [
            [:in_bed_start_scheduled, :in_bed_end_scheduled],
            [:out_of_bed_start_scheduled, :out_of_bed_end_scheduled],
            [:sleep_start_scheduled, :sleep_end_scheduled],
            [:wake_start_scheduled, :wake_end_scheduled],
            [:lighting_block_start_scheduled, :lighting_block_end_scheduled]
        ],
        conditions: {
            [/In Bed/, /005/] => {
                event_map: [ {name: :in_bed_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :out_of_bed_end_scheduled, existing_records: :destroy, labtime_fn: :from_s} ],
                column_map: [ {target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                capture_map: []
            },
            [/Out of Bed/, /005/] => {
                event_map: [{name: :out_of_bed_start_scheduled, existing_records: :destroy, labtime_fn: :from_s},  {name: :in_bed_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                capture_map: []
            },
            [/Lighting Change Lux=(\d+)/, /024/] => {
                event_map: [{name: :lighting_block_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :lighting_block_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                capture_map: [{target: :datum, name: :lighting_block_start_scheduled, field: :light_level}]
            },
            [/Sleep Episode #(\d+) Lux=(\d+)/, /022/] => {
                event_map: [{name: :lighting_block_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :sleep_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :sleep_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :lighting_block_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                capture_map: [
                    {target: :datum, name: :sleep_start_scheduled, field: :episode_number},
                    {target: :datum, name: :lighting_block_start_scheduled, field: :light_level}
                ]
            },
            [/Wake Time #(\d+) Lux=(\d+)/, /023/] => {
                event_map: [{name: :lighting_block_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :wake_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :wake_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :lighting_block_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                capture_map: [
                    {target: :datum, name: :wake_start_scheduled, field: :episode_number},
                    {target: :datum, name: :lighting_block_start_scheduled, field: :light_level}
                ]
            },
            [] => {
                event_map: [{name: :new_forms_event, existing_records: :destroy, labtime_fn: :from_s}],
                column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :datum, field: :event_description}, {target: :datum, field: :event_code}, {target: :subject_code_verification}],
                capture_map: []
            }
        }
    }

    def initialize(root_path, merged_file_dir, subject_group, documentation, source_type, user, refresh = false)
      @root_path = root_path
      @merged_file_dir = merged_file_dir
      @subject_group = subject_group
      @documentation = documentation
      @source_type = source_type
      @user = user
      @refresh = refresh
    end

    def search_root
      save_name = "new_forms_t_drive_results.yaml"
      save_path = File.join(ETL::SAVED_OBJECT_DIR, save_name)

      if @refresh or !File.exists?(save_path)
        @t_drive_results = ETL::TDriveCrawler.get_file_list(:dbf, :new_forms, @subject_group, @root_path)
        File.open(save_path, 'w') {|f| f.write(YAML.dump(@t_drive_results))}
        t_drive_details = ETL::TDriveCrawler.understand_dbf(@t_drive_results)

        LOAD_LOG.info "\n###\nDetails about T Drive File List:\n#{t_drive_details.to_yaml}\n###\n"
      else
        @t_drive_results = YAML.load(File.read(save_path))
      end

    end

    def merge_files
      save_name = "new_forms_merged_file_list.yaml"
      save_path = File.join(ETL::SAVED_OBJECT_DIR, save_name)
      files_exist = true

      @merged_files = YAML.load(File.read(save_path)) if File.exists?(save_path)
      @merged_files.each {|mf| files_exist = false unless File.readable?(mf[:path])}

      if @refresh or !files_exist
        merger = ETL::DbfFileMerger.new(@t_drive_results, @merged_file_dir, MERGED_FILE_PREFIX, NEW_FORMS_COLUMNS)
        @merged_files = merger.merge
        File.open(save_path, 'w') {|f| f.write(YAML.dump(@merged_files))}
      else
        @merged_files = YAML.load(File.read(save_path))
      end

    end

    def load_events
      successful_subjects = []
      unsuccessful_subjects = []

      @merged_files.each do |file_info|
        begin
          LOAD_LOG.info "\n##\nLoading new forms events for #{file_info[:subject].subject_code}"

          source = Source.find_by_location file_info[:path]
          source ||= Source.create(location: file_info[:path], description: "Merged NewForms.dbf file for subject #{file_info[:subject].subject_code}.\nnumber of rows: #{file_info[:total_rows]}\nSources for file data:\n#{file_info[:source_info].join("\n")}", source_type_id: @source_type.id, user_id: @user.id)

          dbf_loader = ETL::DbfLoader.new(file_info[:path], DBF_LOADER_CONFIG, source, @documentation, file_info[:subject])
          dbf_loader.load
          successful_subjects << file_info[:subject].subject_code
          LOAD_LOG.info "##\nFinished loading new forms events for #{file_info[:subject].subject_code}\n"
        rescue Exception => e
          unsuccessful_subjects << file_info[:subject].subject_code
          LOAD_LOG.error "\n#############!!!!!\nNew Forms Loader Exception for \n#{file_info.to_yaml}\n!!!!\n#{e.message}\n\n#{e.backtrace.inspect}#############!!!!!\n\n"
        end
      end

      summary = "\n################################\nFinished Loading new forms for all Subjects!\nsuccessful: (#{successful_subjects.length}) #{successful_subjects}\nunsuccessful: (#{unsuccessful_subjects.length}) #{unsuccessful_subjects}\n################################\n\n\n"

      LOAD_LOG.info summary
      MY_LOG.info summary

    end


  end
end