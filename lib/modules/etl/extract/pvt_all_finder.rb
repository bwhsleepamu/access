require "find"

module ETL
  class PvtAllFinder

    def self.info(inpath, outpath)
      out = CSV.open(outpath, 'wb')
      info = {}

      Find.find(inpath) do |p|
        if p =~ /\.xls$/
          MY_LOG.info "Checking #{p}"
          s = Roo::Excel.new(p)
          info[p] = {}
          info[p][:sheets] = s.sheets

          possible_fevs = s.sheets.select {|x| (x =~ /acceptable/i or x =~ /pvt.*fev/i)}
          if possible_fevs.length == 1
            fev_sheet = s.sheet(possible_fevs.first)
            #info[p][:stats] = [fev_sheet.first_row, fev_sheet.last_row, fev_sheet.first_column, fev_sheet.last_column]
            source = Source.find_by_location(p)

            sid = (source.nil? ? nil : source.id)

            out << [sid, p, possible_fevs.first] + fev_sheet.row(1)
          else
            MY_LOG.info "CAN'T FIND FEV SHEET #{p}"
          end

        end
      end
      out.close
      MY_LOG.info info.to_yaml
    end

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