require "find"

module ETL
  class PvtAllFinder


    def initialize(subject_group_list, dest_dir, descriptions, patterns)
      @subject_group_list = subject_group_list
      @dest_dir = dest_dir
      @descriptions = descriptions
      @patterns = patterns
    end

    def find_and_stage

    end

    def explore
      targets = {}
      sources = []
      source_type = SourceType.find_by_name("Excel File")


      Source.transaction do
        @subject_group_list.each_pair do |subject_group, dir|
          subject_group.subjects.each do |subject|
            subject_dir = File.join(dir, subject.subject_code)
            output_dir = File.join(@dest_dir, subject.subject_code)
            Dir.mkdir(output_dir) unless File.directory? output_dir

            targets[subject.subject_code] = []

            if File.directory? subject_dir
              Find.find(subject_dir) do |path|
                if path =~ @patterns[subject_group.name]
                  MY_LOG.info "#{subject.subject_code} Adding: #{path}"
                  targets[subject.subject_code] << path
                  output_path = File.join(output_dir, File.basename(path))
                  FileUtils.cp(path, output_path)
                  sources << Source.create(location: output_path, original_location: path, subject: subject, description: @descriptions[subject_group.name], source_type: source_type)
                end
              end
            else
              MY_LOG.info "#{subject.subject_code}: Can't find #{subject_dir}"
            end

          end
        end
      end

      LOAD_LOG.info "PVT_FILES FOUND:\n#{targets.to_yaml}\n\n"
      LOAD_LOG.info "#{sources.length} Sources Created:\n#{sources.map{|s| "#{s.subject}: #{s.location}\n"}}\n\n"
      LOAD_LOG.info sources.map(&:location)
    end
  end
end