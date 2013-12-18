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
    task :subject_information => :environment do
      subject_info_files = [
        {
          source_path: "/I/Projects/Database Project/Data Sources/Forced Desynchrony Subject Information/DSMDB_FD_Study_Info_2013_12_09.xls",
          subject_type: :forced_desynchrony,
          source: Source.find_by_id(92806902),
          documentation: Documentation.find_by_id(10040)
        }
        #{
        #  source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/joshua_gooley_subject_information/subject_information.xls",
        #  subject_type: :light,
        #  source: Source.find_by_id(10001),
        #  documentation: Documentation.find_by_id(10000)
        #},
        #{
        #  source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/melanie_rueger_subject_information/subject_information.xls",
        #  subject_type: :light,
        #  source: Source.find_by_id(10002),
        #  documentation: Documentation.find_by_id(10000)
        #},
        #{
        #  source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/melissa_st_hilaire_subject_information/subject_information.xls",
        #  subject_type: :light,
        #  source: Source.find_by_id(10003),
        #  documentation: Documentation.find_by_id(10000)
        #},
        #{
        #  source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/shadab_rahman_subject_information/subject_information.xls",
        #  subject_type: :light,
        #  source: Source.find_by_id(10004),
        #  documentation: Documentation.find_by_id(10000)
        #},
        #{
        #  source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/steve_lockley_subject_information/subject_information.xls",
        #  subject_type: :light,
        #  source: Source.find_by_id(10005),
        #  documentation: Documentation.find_by_id(10000)
        #},
        #{
        #  source_path: "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Light Subject Information/anne_marie_chang_subject_information/subject_information.xls",
        #  subject_type: :light,
        #  source: Source.find_by_id(10000),
        #  documentation: Documentation.find_by_id(10000)
        #}
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
    task :actigraphy => :environment do

#      subjects = ["1425MX72", "1637XX", "1684MX", "1691MX", "1736MX", "1772MX", "1776MX", "1795MX", "1834MX", "1873MX", "1888XX", "1889MX", "18B2XX", "18E3XX", "18E4MX", "1903MX", "1963XX", "19A4W", "2072W1T2", "2082W1T2", "2093HM", "20B1HM", "20C1DX", "2109W", "2111W", "2123W", "2150DX", "2195W", "2196W", "2199HM", "21A4DX", "2210W", "2238DX", "2249HM", "22F2W", "22T1W", "2310HM", "2313W", "24B7GXT3", "25R8GXT2", "26N2GXT2", "2709HX", "2760GXT2", "2768X", "2788X", "27B2X", "27D9GX", "27Q9GX", "2819X", "2823GX", "2844GX", "2890X", "2895X", "28B2X", "28G1HX", "28K5X", "28Q6X", "28Q9HX", "2903X", "29D7X", "29N1HX", "3007HX", "3046HX", "3227GX", "3228GX"]
      subject_group = SubjectGroup.find_by_name("sazuka_actigraphy")
      subjects = subject_group.subjects

      successful_subjects = []
      unsuccessful_subjects = []

      subjects.each do |subject|
        al = ETL::ActigraphyLoader.new(subject.subject_code, "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/Merged Files", "I:/Projects/Database Project/Data Sources/Actigraphy/Merged Files", true)
        loaded = al.load_subject

        if loaded
          successful_subjects << subject.subject_code
        else
          unsuccessful_subjects << subject.subject_code
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

    desc "load scored PVT data (CSR_32d_FD_20h)"
    task :pvt_all => :environment do
      successful_subjects = []
      unsuccessful_subjects = []


      description = "Cleaned Visual PVT-All file created by Joe Hull"
      documentation = Documentation.find(10181)

      inputs =
      [
        { subject_code: "3227GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3227GX/Neurobehavioral_3227GX/VPVTALL_3227GX.xls" },
        { subject_code: "3228GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3228GX/Neurobehavioral_3228GX/VPVTALL_3228GX.xls" },
        { subject_code: "3232GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3232GX/Neurobehavioral_3232GX/VPVTALL_3232GX.xls" },
        { subject_code: "3233GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3233GX/Neurobehavioral_3233GX/VPVTALL_3233GX.xls" },
        { subject_code: "3237GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3237GX_D/Neurobehavioural_3237GX/VPVTALL_3237GX.xls" },
        { subject_code: "3315GX32", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3315GX32/Neurobehavioral_3315GX32/VPVTALL_3315GX32.xls" },
        { subject_code: "3319GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3319GX/Neurobehavioral_3319GX/VPVTALL_3319GX.xls" },
        { subject_code: "3335GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3335GX/Neurobehavioral_3335GX/VPVTALL_3335GX.xls" },
        { subject_code: "3339GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3339GX/Neurobehavioral_3339GX/VPVTALL_3339GX.xls" }
      ]

      inputs.each do |input|
        subject = Subject.find_by_subject_code(input[:subject_code])
        raise StandardError unless subject
        source = Source.find_by_location input[:path]
        source = Source.create(location: input[:path], source_type_id: SourceType.find_by_name("Excel File").id, user_id: User.find_by_email("pmankowski@partners.org").id, description: description ) unless source

        @pvt_loader = ETL::PvtLoader.new(subject, source, documentation)
        if @pvt_loader.load_subject
          successful_subjects << subject
        else
          unsuccessful_subjects << subject
        end
      end

      LOAD_LOG.info "\n################################\nFinished Loading PVT ALL DATA for all Subjects!\nsuccessful: #{successful_subjects.map(&:subject_code)}\nunsuccessful: #{unsuccessful_subjects.map(&:subject_code)}\n################################\n\n\n"
    end


    desc "load cleaned VAS(mood, short mood) data (CSR_32d_FD_20h)"
    task :vas => :environment do
      successful_subjects = []
      unsuccessful_subjects = []

      description = "Cleaned Visual Analog Sclae (Scalesad) file created by Joe Hull"
      documentation = Documentation.find(92983582)

      inputs =
      [
          { subject_code: "3227GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3227GX/Neurobehavioral_3227GX/SCALES_3227GX.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3227GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3227GX/Neurobehavioral_3227GX/Sscales_3227GX.xls", event_name_base: 'vas_shtscale'},
          { subject_code: "3228GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3228GX/Neurobehavioral_3228GX/SCALES_3228GX.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3228GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3228GX/Neurobehavioral_3228GX/Sscales_3228GX.xls", event_name_base: 'vas_shtscale'},
          { subject_code: "3232GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3232GX/Neurobehavioral_3232GX/SCALES_3232GX.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3232GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3232GX/Neurobehavioral_3232GX/Sscales_3232GX.xls", event_name_base: 'vas_shtscale'},
          { subject_code: "3233GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3233GX/Neurobehavioral_3233GX/SCALES_3233GX.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3233GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3233GX/Neurobehavioral_3233GX/Sscales_3233GX.xls", event_name_base: 'vas_shtscale'},
          { subject_code: "3237GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3237GX_D/Neurobehavioural_3237GX/SCALES_3237GX.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3237GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3237GX_D/Neurobehavioural_3237GX/Sscales_3237GX.xls", event_name_base: 'vas_shtscale'},
          { subject_code: "3315GX32", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3315GX32/Neurobehavioral_3315GX32/SCALES_3315GX32.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3315GX32", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3315GX32/Neurobehavioral_3315GX32/Sscales_3315GX32.xls", event_name_base: 'vas_shtscale'},
          { subject_code: "3319GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3319GX/Neurobehavioral_3319GX/SCALES_3319GX.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3319GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3319GX/Neurobehavioral_3319GX/Sscales_3319GX.xls", event_name_base: 'vas_shtscale'},
          { subject_code: "3335GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3335GX/Neurobehavioral_3335GX/SCALES_3335GX.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3335GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3335GX/Neurobehavioral_3335GX/Sscales_3335GX.xls", event_name_base: 'vas_shtscale'},
          { subject_code: "3339GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3339GX/Neurobehavioral_3339GX/SCALES_3339GX.xls", event_name_base: 'vas_scalesad'},
          { subject_code: "3339GX", path: "/X/Studies/Analyses/CSR_32d_FD_20h/3339GX/Neurobehavioral_3339GX/Sscales_3339GX.xls", event_name_base: 'vas_shtscale'}
      ]


      inputs.each do |input|
        subject = Subject.find_by_subject_code(input[:subject_code])
        raise StandardError unless subject
        source = Source.find_by_location input[:path]
        source = Source.create(location: input[:path], source_type_id: SourceType.find_by_name("Excel File").id, user_id: User.find_by_email("pmankowski@partners.org").id, description: description ) unless source

        @vas_loader = ETL::VasLoader.new(subject, source, documentation, input[:event_name_base])
        if @vas_loader.load_subject
          successful_subjects << subject
        else
          unsuccessful_subjects << subject
        end
      end



      LOAD_LOG.info "\n################################\nFinished Loading VAS DATA for all Subjects!\nsuccessful: #{successful_subjects.map(&:subject_code)}\nunsuccessful: #{unsuccessful_subjects.map(&:subject_code)}\n################################\n\n\n"


    end


    desc "load Sleep Data"
    task :sleep_data => :environment do
      successful_subjects = []
      unsuccessful_subjects = []

      description = "Sleep Data File created by Elizabeth Klerman"
      documentation = Documentation.find(93232402)

      subject_group = SubjectGroup.find_by_name("beth_raster_plots")

      subject_group.subjects.each do |subject|
        file_path = File.join("/I/AMU Cleaned Data Sets/", subject.subject_code, "Sleep", "#{subject.subject_code}Sleep.xls")
        unless File.exists? file_path
          LOAD_LOG.info "ERROR: #{file_path} does not exist!"
          unsuccessful_subjects << subject.subject_code
          next
        end

        source = Source.find_by_location(file_path)
        source ||= Source.create(location: file_path,
                                 source_type_id: SourceType.find_by_name("Excel File").id,
                                 user_id: User.find_by_email("pmankowski@partners.org").id,
                                 description: description )
        loader = ETL::SleepDataLoader.new(subject, source, documentation)

        if loader.load_subject
          successful_subjects << subject.subject_code
        else
          unsuccessful_subjects << subject.subject_code
        end


      end

      LOAD_LOG.info "\n################################\nFinished Loading Sleep Data for all Subjects!\nsuccessful: #{successful_subjects}\nunsuccessful: #{unsuccessful_subjects}\n################################\n\n\n"
    end
  end

  namespace :transform do
    desc "merge actigraphy"
    task :merge_actigraphy => :environment do
      subject_group = SubjectGroup.find_by_name("sazuka_actigraphy")
      subjects = subject_group.subjects#.select{|s| s.subject_code == "3121V"}

      al = ETL::ActigraphyMerger.new("/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/LS-Actigraphy_2012.12.17.csv", "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/Merged Files/", subjects)
      al.merge_files
    end
  end

end
