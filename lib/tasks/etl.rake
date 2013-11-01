# example command:
# bundle exec rake etl:klerman_light_study_demographics_spreadsheet --trace RAILS_ENV=production

namespace :etl do
  namespace :load do

    desc "load sleep stage data into database"
    task :sleep_stage_data => :environment do
      #subjects = %w(26N2GXT2 26O2GXT2 27D9GX 27Q9GX 1708XX 1920MX 2071DX 2123W 2419HM 2823GX 2844GX 3232GX)
      #subjects = %w(1105X 1106X 1111X 1120X 1122X 1133X 1136X 1144X 1145X 1209V 1213HX 1215H 1257V 1304HX 1319HX 1355H 1366HX 1375HX 1425MX72 1458HX 1475HX 1485HX 1490HX 14A6HX 1507HX 1547MX62 1620XX 1637XX 1649XX 1683XX 1684MX 1691MX 1702MX 1708XX 1712MX 1722MX 1725MX 1732MX 1734XX 1736MX 1742MX 1745MX 1750XX 1755MX 1760MX 1764MX 1772MX 1772XXT2 1776MX 1777MX 1779MX 1795MX 1798MX 1800XX 1818MX 1819XX 1825MX 1834MX 1835XX 1851MX 1854MX 1871MX 1873MX 1888XX 1889MX 18B2XX 18E3XX 18E4MX 18H4MX 18H5MX 18I9MX 18K1XX 1903MX 1905MX 1920MX 1963XX 19G3HM 2065DX 2072DX 2072W1T2 2082W1T2 2093HM 20A4DX 20B1HM 20B7DX 20C1DX 2109W 2111DX 2111W 2138DX 2140DX 2149DX 2150DX 2152DX 2173DX 2195W 2196W 2199HM 21A4DX 21B3DX 2209W 2210W 2238DX 2249HM 22B1DX 22C5DX 22F2W 22T1W 2310HM 2313W 23C2HM 23CDHM 23CEHM 23DHHM 24B7GXT3 25R8GXT2 2760GXT2 3227GX 3228GX26N2GXT2 26O2GXT2 27D9GX 27Q9GX 1708XX 1920MX 2071DX 2123W 2419HM 2823GX 2844GX 3232GX)
      LOAD_LOG.info "################# Sleep Stage Info ##################"
      parent_path = "/home/pwm4/Windows/idrive/AMU Cleaned Data Sets"
      location = "I:/AMU Cleaned Data Sets"

      subject_group = SubjectGroup.find_by_name("authorized")
      subjects = subject_group.subjects

      loaded = []
      failed = []
      skipped = []

      subjects.each do |subject|
        if Event.current.where(subject_id: subject.id, name: 'scored_epoch').count == 0
          loader = ETL::SleepStageLoader.new(subject.subject_code, parent_path, location)
          loader.load_subject ? loaded << subject.subject_code : failed << subject.subject_code
        else
          skipped << subject.subject_code
        end
      end

      LOAD_LOG.info "loaded subjects: #{loaded.join("', '")}\nfailed subjects: #{failed.join("', '")}\nskipped subjects: #{skipped.join("', '")}"
      LOAD_LOG.info "#####################################################"
    end

    desc "load subject information"
    task :load_subject_information => :environment do
      subject_info_files = [
        {
          source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Forced Desynchrony Subject Information/DSMDB_FD_Study-Info_05.22.2013.xls",
          subject_type: :forced_desynchrony,
          source: Source.find_by_id(10210),
          documentation: Documentation.find_by_id(10040)
        },
        {
          source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/joshua_gooley_subject_information/subject_information.xls",
          subject_type: :light,
          source: Source.find_by_id(10001),
          documentation: Documentation.find_by_id(10000)
        },
        {
          source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/melanie_rueger_subject_information/subject_information.xls",
          subject_type: :light,
          source: Source.find_by_id(10002),
          documentation: Documentation.find_by_id(10000)
        },
        {
          source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/melissa_st_hilaire_subject_information/subject_information.xls",
          subject_type: :light,
          source: Source.find_by_id(10003),
          documentation: Documentation.find_by_id(10000)
        },
        {
          source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/shadab_rahman_subject_information/subject_information.xls",
          subject_type: :light,
          source: Source.find_by_id(10004),
          documentation: Documentation.find_by_id(10000)
        },
        {
          source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/steve_lockley_subject_information/subject_information.xls",
          subject_type: :light,
          source: Source.find_by_id(10005),
          documentation: Documentation.find_by_id(10000)
        },
        {
          source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/anne_marie_chang_subject_information/subject_information.xls",
          subject_type: :light,
          source: Source.find_by_id(10000),
          documentation: Documentation.find_by_id(10000)
        }
      ]

      subject_info_files.each do |si_file|
        #LOAD_LOG.info "LOADING: #{si_file}"
        si_loader = ETL::SubjectInformationLoader.new(si_file[:source_path], si_file[:subject_type], si_file[:source], si_file[:documentation])
        si_loader.load
      end
    end

    desc "load subject demographics"
    task :load_subject_demographics => :environment do
      subject_dem_files = [
        #{
        #    source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Demographics/LS_DEMO_20120605_CLEANED_20130506_MAIN.xls",
        #    subject_type: :light,
        #    source: Source.find_by_id(10111),
        #    documentation: Documentation.find_by_id(10041)
        #},
        {
            source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Demographics/FD_DEMO_20130314_CLEANED_20130506.xls",
            subject_type: :forced_desynchrony,
            source: Source.find_by_id(10230),
            documentation: Documentation.find_by_id(10041)
        }
      ]

      subject_dem_files.each do |sd_file|
        sd_loader = ETL::SubjectDemographicsLoader.new(sd_file[:source_path], sd_file[:subject_type], sd_file[:source], sd_file[:documentation])
        sd_loader.load
      end


    end

    desc "load nosa information for fd subjects"
    task :load_nosa_fd => :environment do
      file_info = {
          source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Circadian Phase and Period/FD-info 2013a.xls",
          source: Source.find_by_id(10390),
          documentation: Documentation.find_by_id(10081)
      }

      nosa_loader = ETL::FdNosaInformationLoader.new(file_info[:source_path], file_info[:source], file_info[:documentation])
      nosa_loader.load
    end


    desc "load actigraphy"
    task :load_actigraphy => :environment do
      subjects = ["1425MX72", "1637XX", "1684MX", "1691MX", "1736MX", "1772MX", "1776MX", "1795MX", "1834MX", "1873MX", "1888XX", "1889MX", "18B2XX", "18E3XX", "18E4MX", "1903MX", "1963XX", "19A4W", "2072W1T2", "2082W1T2", "2093HM", "20B1HM", "20C1DX", "2109W", "2111W", "2123W", "2150DX", "2195W", "2196W", "2199HM", "21A4DX", "2210W", "2238DX", "2249HM", "22F2W", "22T1W", "2310HM", "2313W", "24B7GXT3", "25R8GXT2", "26N2GXT2", "2709HX", "2760GXT2", "2768X", "2788X", "27B2X", "27D9GX", "27Q9GX", "2819X", "2823GX", "2844GX", "2890X", "2895X", "28B2X", "28G1HX", "28K5X", "28Q6X", "28Q9HX", "2903X", "29D7X", "29N1HX", "3007HX", "3046HX", "3227GX", "3228GX"]
      successful_subjects = []
      unsuccessful_subjects = []

      subjects.each do |subject|
        al = ETL::ActigraphyLoader.new(subject, "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/Merged Files", "I:/Projects/Database Project/Data Sources/Actigraphy/Merged Files", true)
        loaded = al.load_subject

        if loaded
          successful_subjects << subject
        else
          unsuccessful_subjects << subject
        end
      end

      LOAD_LOG.info "\n################################\nFinished Loading actigraphy for all Subjects!\nsuccessful: #{successful_subjects}\nunsuccessful: #{unsuccessful_subjects}\n################################\n\n\n"

    end

    desc "load NewForms.dbf"
    task :load_new_forms => :environment do
      root_path = "/home/pwm4/Windows/tdrive/IPM"
      merged_files_path = "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/T_DRIVE/Merged NewForms/"
      documentation = Documentation.find(10101)
      source_type = SourceType.find(10022)
      user = User.find_by_email("pmankowski@partners.org")
      subject_group = SubjectGroup.find_by_name("authorized")

      new_forms_loader = ETL::NewFormsLoader.new(root_path, merged_files_path, subject_group, documentation, source_type, user)

      new_forms_loader.search_root
      new_forms_loader.merge_files
      new_forms_loader.load_events
    end
  end

  namespace :transform do
    desc "merge fd actigraphy"
    task :merge_fd_actigraphy => :environment do
      al = ETL::ActigraphyMerger.new("/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/FD-Actigraphy_2013.05.17.csv", "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/Merged Files/")
      al.merge_files
    end
  end

end
