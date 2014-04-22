require "find"

module ETL
  class TDriveCrawler
    # Given a list of subjects (or a tag?) and file type?
    # gets matching list of files for each subject

    T_DRIVE_ROOT = "/home/pwm4/Windows/tdrive/IPM"

    FILE_TYPE_LIST = {
        dbf: {
            new_forms: {source_type_id: 10022, pattern: /.*NewForms.*\.dbf\z/i}
        },
        sh: {

        }

    }

    ## TEST FUNCTION
    def self.gather_stats
      stats = {}
      subjects_in_list = []
      bad_sc = []
      subjects_rejected = []

      Find.find('/home/pwm4/Windows/tdrive/IPM') do |f|
        if FILE_TYPE_LIST[:dbf][:new_forms][:pattern].match f
          sc_match = Regexp.new("\\/" + Subject::SUBJECT_CODE_REGEX.source + "\\/", true).match f
          if sc_match
            if SubjectGroup.find_by_name("authorized").subjects.find_by_subject_code(sc_match[1])
              stats[sc_match[1]] ||= {count: 0, file_names: []}
              stats[sc_match[1]][:file_names] << f
              stats[sc_match[1]][:count] += 1
              subjects_in_list << sc_match[1]
            else
              subjects_rejected << sc_match[1]
            end

          else
            MY_LOG.error "!!!!!!: #{f}"
            bad_sc << f
          end
        end
      end

      MY_LOG.info stats.to_yaml
      MY_LOG.info "found: (#{subjects_in_list.uniq.length}) #{subjects_in_list.uniq}"
      MY_LOG.info "rejected: (#{subjects_rejected.uniq.length}) #{subjects_rejected.uniq}"
      MY_LOG.info "number of bad sc: #{bad_sc.length}"
    end

    def self.get_file_list(type, name, subject_group = nil, root_path = T_DRIVE_ROOT)
      file_list = {}
      subjects_rejected = []
      bad_subject_code = []
      match_count = 0

      subject_list = subject_group ? subject_group.subjects : Subject.current

      #source_type = SourceType.find(FILE_TYPE_LIST[type][name][:source_type_id])
      LOAD_LOG.info "##### Searching for Subject Files #####"

      Find.find(root_path) do |f|
        #MY_LOG.info "SEARCHING DIR: #{f}" if /.*IPM\/[^\/]*\/[^\/]*\z/i.match f
        if FILE_TYPE_LIST[type][name][:pattern].match f
          match_count += 1
          sc_match = Regexp.new("\\/" + Subject::SUBJECT_CODE_REGEX.source + "\\/", true).match f
          if sc_match
            # Subject Code folder found in file path
            subject_code = sc_match[1]
            if subject_list.find_by_subject_code(subject_code)
              # Subject in list of subjects to be loaded
              LOAD_LOG.info "Adding #{subject_code}!"
              file_list[subject_code] ||= []
              file_list[subject_code] << f
            else
              subjects_rejected << subject_code
            end

          else
            # No clear subject code folder found in file path. TODO: Add functionality to account for a wider range of folder names

            # For these files, maybe suggest a subject code by looking inside the file.
            bad_subject_code << f
          end
          LOAD_LOG.info "Searched through #{match_count} matches so far..." if match_count % 100 == 0
        end
      end

      #LOAD_LOG.info "\nSubject Group: '#{subject_group_name}'\nFile Type: #{type} - #{name}\nSource Type: #{source_type.name}"
      LOAD_LOG.info "Subjects with at least one file found (#{file_list.keys.length}): #{file_list.keys}"
      LOAD_LOG.info "Subjects not in desired group (#{subjects_rejected.uniq.length}): #{subjects_rejected.uniq}"
      LOAD_LOG.info "No Subject Folder found (#{bad_subject_code.length}): #{bad_subject_code}"
      LOAD_LOG.info "#######################################"

      file_list
    end

    def self.understand_dbf(file_list)
      details = {}
      file_list.each do |subject_code, dbf_files|
        details[subject_code] ||= {}
        details[subject_code][:file_count] = dbf_files.length
        details[subject_code][:file_details] = []
        details[subject_code][:sc_match] = true

        dbf_files.each do |dbf_file_path|
          dbf_reader = ETL::DbfReader.open(dbf_file_path)


          details[subject_code][:file_details] << {
              name: File.basename(dbf_file_path),
              row_count: dbf_reader.length,
              columns: dbf_reader.columns,
              first_labtime: dbf_reader.row_index("LABTIME").present? ? dbf_reader.contents.first[dbf_reader.row_index("LABTIME")] : nil,
              last_labtime: dbf_reader.row_index("LABTIME").present? ? dbf_reader.contents.last[dbf_reader.row_index("LABTIME")] : nil,
              subject_code: dbf_reader.row_index("SUBJECT").present? ? dbf_reader.contents.first[dbf_reader.row_index("SUBJECT")] : nil
          }
          details[subject_code][:sc_match] = details[subject_code][:sc_match] ? details[subject_code][:file_details].last[:subject_code] == subject_code : details[subject_code][:sc_match]
          dbf_reader.close
        end
      end

      details
    end

    def self.find_subject_directory(subject, root_path = T_DRIVE_ROOT, search_t_drive)
      subject_dirs = []

      # Add all possible variations of t drive location
      if subject.t_drive_location.present?
        t_drive_dir_transformed = self.standardize_location(subject.t_drive_location)
        if File.basename(subject.t_drive_location).upcase == subject.subject_code
          subject_dirs << subject.t_drive_location
          subject_dirs << t_drive_dir_transformed
        elsif File.basename(subject.t_drive_location) =~ /#{subject.subject_code}/i
          MY_LOG.info "WARNING: UNCONVENTIONAL T DRIVE LOCATION: #{subject.t_drive_location}"
          subject_dirs << subject.t_drive_location
          subject_dirs << t_drive_dir_transformed
        else
          subject_dirs << File.join(subject.t_drive_location, subject.subject_code)
          subject_dirs << File.join(subject.t_drive_location, subject.subject_code.downcase)
          subject_dirs << File.join(t_drive_dir_transformed, subject.subject_code)
          subject_dirs << File.join(t_drive_dir_transformed, subject.subject_code.downcase)
        end

        #MY_LOG.info "#{subject.t_drive_location} | #{t_drive_dir_transformed} | #{subject_dirs} | #{subject_dirs.uniq.keep_if { |d| File.directory? d }}"

        subject_dirs = subject_dirs.uniq.keep_if do |d|
          # Checks if directory is part of directory list of it's parent folder
          # Replaced just File.directory? d since that did not account for capitalization differences

          File.directory?(d) && Dir[File.dirname(d)+"/*"].include?(d)
        end
      end

      # If folder cannot be found using t drive location, search T drive
      if subject_dirs.empty? and search_t_drive
        Find.find(root_path) do |path|
          if FileTest.directory?(path)
            if File.basename(path).upcase == subject.subject_code
              subject_dirs << path
              Find.prune
            end
          end
        end
      end

      # What if more than one folder is found?
      raise StandardError, "Error with: #{subject_dirs}" if subject_dirs.length > 1

      subject_dirs.first

    end

    def self.populate_t_drive_location(subject_group, root_path = T_DRIVE_ROOT)
      subject_codes = subject_group.subjects.map(&:subject_code)
      t_drive_loc_map = {}
      subject_codes.each {|sc| t_drive_loc_map[sc] = []}

      results = {none_found: [], locations_differ: [], locations_same: [], new_set: [], multiple_found: []}

      start = Time.now

      Find.find(root_path) do |path|
        if FileTest.directory?(path)
          if Time.now - start > 60
            start = Time.now

            LOAD_LOG.info "current path: #{path} results: #{results}"
          end
          possible_subject_code = File.basename(path.upcase)
          if possible_subject_code =~ Subject::SUBJECT_CODE_REGEX && subject_codes.include?(possible_subject_code)
            t_drive_loc_map[possible_subject_code] << path

            Find.prune
          end
        end
      end

      t_drive_loc_map.each_pair do |sc, locations|

        if locations.length == 0
          LOAD_LOG.info "No T drive location found for subject #{sc}!"
          results[:none_found] << sc
        elsif locations.length == 1
          s = Subject.find_by_subject_code sc
          new_location = locations.first
          if s.t_drive_location.present?
            if new_location != self.standardize_location(s.t_drive_location)
              LOAD_LOG.info "Warning!! For subject #{sc}, T drive location found (#{new_location}) is different than current T drive location (#{s.t_drive_location}. No change will be made."
              results[:locations_differ] << sc
            else
              LOAD_LOG.info "For subject #{sc}, found T drive location is the same as current location. No change will be made."
              results[:locations_same] << sc
            end
          else
            LOAD_LOG.info "The following T drive locations is being set for subject #{sc}: #{new_location}."
            s.update_attribute(:t_drive_location, new_location)
            results[:new_set] << sc
          end
        else
          LOAD_LOG.info "Warning!! Multiple locations found for subject #{sc}: #{locations}"
          results[:multiple_found] << sc
        end
      end

      results
    end

    private

    def self.standardize_location(loc)
      loc.gsub(/(^\w)/, '/\1').gsub(':', '')
    end



  end
end
