require "find"

module ETL
  class TDriveCrawler
    # Given a list of subjects (or a tag?) and file type?
    # gets matching list of files for each subject

    T_DRIVE_ROOT = "/home/pwm4/Windows/tdrive/IPM"

    FILE_TYPE_LIST = {
        dbf: {
            new_forms: {source_type_id: 10022, pattern: /.*NewForms.*\.dbf\z/i}
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

    def self.get_file_list(type, name, subject_group, root_path)
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

  end
end