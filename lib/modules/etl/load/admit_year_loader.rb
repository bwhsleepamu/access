module ETL
  class AdmitYearLoader
    def self.populate_admit_year(subject_group, root_path = nil)

      #results = {none_found: [], year_differs: [], year_same: [], new_set: []}

      # Sources:
      ## Subject Code
      ## Subject.admit_year
      ## patient_year = get_year(File.join(parent_path, subject_code, "Sleep", xls_file_name)) from AMU CLEANED!
      ## Schedule.RPJ
      results = {same: [], different: [], inserted: [], no_sc_match: [], not_found: []}

      subject_group.subjects.each do |subject|
        subject_dir = ETL::TDriveCrawler.find_subject_directory(subject, nil, false)

        if subject_dir
          Find.find(subject_dir) do |path|
            if File.basename(path) =~ /.*schedule.*\.rpj$/i
              File.open(path).read =~ /Study_Year=\s*(\d{4})/i
              MY_LOG.info "#{subject.subject_code} || #{subject.admit_year} | #{$1} | #{self.get_year_from_subject_code(subject.subject_code)} || #{path}"
              found_year = $1.to_i
              sc_year = self.get_year_from_subject_code(subject.subject_code)

              if subject.admit_year.present?
                if subject.admit_year == found_year
                  LOAD_LOG.info "#{subject.subject_code}: Current and found years match! #{subject.admit_year} | #{found_year} | #{sc_year}"
                  results[:same] << subject.subject_code
                else
                  LOAD_LOG.info "#{subject.subject_code}: WARNING! Current and found years do not match! #{subject.admit_year} | #{found_year} | #{sc_year}"
                  results[:different] << subject.subject_code
                end
              else
                if found_year == sc_year
                  LOAD_LOG.info "#{subject.subject_code}: Loading new admit year! #{found_year} | #{sc_year}"
                  results[:inserted] << subject.subject_code
                else
                  LOAD_LOG.info "#{subject.subject_code}: WARNING! Subject code and found year do not match! #{found_year} | #{sc_year}"
                  results[:no_sc_match] << subject.subject_code
                end
                subject.update_attribute(:admit_year, found_year)
              end
            end
          end
        else
          MY_LOG.info "Subject #{subject.subject_code} not found!"
          results[:not_found] << subject.subject_code
        end
      end
      LOAD_LOG.info results
    end

    private

    def self.get_year_from_subject_code(subject_code)
      m = /^(\d\d).*/.match(subject_code)
      m[1].to_i + 1980
    end
  end
end