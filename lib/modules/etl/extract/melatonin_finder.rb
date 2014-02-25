require "find"

module ETL
  class MelatoninFinder
    def initialize(subject_group, dest_dir)
      @subject_group = subject_group
      @dest_dir = dest_dir
    end

    def extract
      source_type = SourceType.find_by_name("Excel File")
      user = User.find_by_email("pmankowski@partners.org")

      @subject_group.subjects.each do |subject|
        LOAD_LOG.info "\n#{subject.subject_code}"
        t_drive_dir = ETL::TDriveCrawler.standardize_location(subject.t_drive_location)
        MY_LOG.info t_drive_dir
        Find.find(t_drive_dir) do |path|
          if (path =~ /_MEL\.xls/i or path =~ /_MEL_merged\.xls/i or path =~ /\/MEL.*\.xls/i) and path !~ /RIA/
            LOAD_LOG.info "#{path}"
            Source.transaction do

              params = {}
              params[:original_location] = path
              params[:location] = File.join(@dest_dir, File.basename(path))
              params[:subject_id] = subject.id
              params[:user_id] = user.id
              params[:source_type_id] = source_type.id

              FileUtils.cp(params[:original_location], params[:location])

              Source.create(params)
            end
          end
        end
      end
    end




      #
      #targets = {}
      #sources = []
      #source_type = SourceType.find_by_name("Excel File")
      #
      #
      #Source.transaction do
      #  @subject_group_list.each_pair do |subject_group, dir|
      #    subject_group.subjects.each do |subject|
      #      subject_dir = File.join(dir, subject.subject_code)
      #      output_dir = File.join(@dest_dir, subject.subject_code)
      #      Dir.mkdir(output_dir) unless File.directory? output_dir
      #
      #      targets[subject.subject_code] = []
      #
      #      if File.directory? subject_dir
      #        Find.find(subject_dir) do |path|
      #          if path =~ @patterns[subject_group.name]
      #            MY_LOG.info "#{subject.subject_code} Adding: #{path}"
      #            targets[subject.subject_code] << path
      #            output_path = File.join(output_dir, File.basename(path))
      #            FileUtils.cp(path, output_path)
      #            sources << Source.create(location: output_path, original_location: path, subject: subject, description: @descriptions[subject_group.name], source_type: source_type)
      #          end
      #        end
      #      else
      #        MY_LOG.info "#{subject.subject_code}: Can't find #{subject_dir}"
      #      end
      #
      #    end
      #  end
#      end

      #LOAD_LOG.info "PVT_FILES FOUND:\n#{targets.to_yaml}\n\n"
      #LOAD_LOG.info "#{sources.length} Sources Created:\n#{sources.map{|s| "#{s.subject}: #{s.location}\n"}}\n\n"
      #LOAD_LOG.info sources.map(&:location)
#    end
  end
end