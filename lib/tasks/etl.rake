# example command:
# bundle exec rake etl:klerman_light_study_demographics_spreadsheet --trace RAILS_ENV=production
# bundle exec rake etl:load:subject_information

namespace :etl do
  namespace :load do

    desc "load sleep stage data into database"
    task :sleep_stage_data => :environment do
      #subjects = %w(26N2GXT2 26O2GXT2 27D9GX 27Q9GX 1708XX 1920MX 2071DX 2123W 2419HM 2823GX 2844GX 3232GX)
      #subjects = %w(1105X 1106X 1111X 1120X 1122X 1133X 1136X 1144X 1145X 1209V 1213HX 1215H 1257V 1304HX 1319HX 1355H 1366HX 1375HX 1425MX72 1458HX 1475HX 1485HX 1490HX 14A6HX 1507HX 1547MX62 1620XX 1637XX 1649XX 1683XX 1684MX 1691MX 1702MX 1708XX 1712MX 1722MX 1725MX 1732MX 1734XX 1736MX 1742MX 1745MX 1750XX 1755MX 1760MX 1764MX 1772MX 1772XXT2 1776MX 1777MX 1779MX 1795MX 1798MX 1800XX 1818MX 1819XX 1825MX 1834MX 1835XX 1851MX 1854MX 1871MX 1873MX 1888XX 1889MX 18B2XX 18E3XX 18E4MX 18H4MX 18H5MX 18I9MX 18K1XX 1903MX 1905MX 1920MX 1963XX 19G3HM 2065DX 2072DX 2072W1T2 2082W1T2 2093HM 20A4DX 20B1HM 20B7DX 20C1DX 2109W 2111DX 2111W 2138DX 2140DX 2149DX 2150DX 2152DX 2173DX 2195W 2196W 2199HM 21A4DX 21B3DX 2209W 2210W 2238DX 2249HM 22B1DX 22C5DX 22F2W 22T1W 2310HM 2313W 23C2HM 23CDHM 23CEHM 23DHHM 24B7GXT3 25R8GXT2 2760GXT2 3227GX 3228GX26N2GXT2 26O2GXT2 27D9GX 27Q9GX 1708XX 1920MX 2071DX 2123W 2419HM 2823GX 2844GX 3232GX)
      root_path = "/I/AMU Cleaned Data Sets"

      subject_group = SubjectGroup.find_by_name("amu_cleaned")
      documentation = Documentation.find(10020)
      source_type = SourceType.find(10120)
      user = User.find_by_email('pmankowski@partners.org')

      loader = ETL::SleepStageLoader.new(root_path, subject_group, source_type, documentation, user)
      loader.load
    end

    desc "load subject information"
    task :subject_information => :environment do
      subject_info_files = [
        {
          # source_path: "/I/Projects/Database Project/Data Sources/Forced Desynchrony Subject Information/DSMDB_FD_Study_Info_HIPAA_2018.11.29.xls",
          source_path: "/home/pwm4/Desktop/temp/DSMDB_FD_Study_Info_HIPAA_2018.11.29.xls"
          subject_type: :forced_desynchrony,
          source: Source.find_by_id(92806902),
          documentation: Documentation.find_by_id(10040)
        }
        # {
        #   source_path: "/I/Projects/Database Project/Data Sources/Forced Desynchrony Subject Information/DSMDB_FD_Study_Info_2013_12_09.xls",
        #   subject_type: :forced_desynchrony,
        #   source: Source.find_by_id(92806902),
        #   documentation: Documentation.find_by_id(10040)
        # }

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


#     # loading performance data (new)
#     desc "load cleaned performance data"
#     task :load_cleaned_performance => :environment do

# #      subjects = ["1425MX72", "1637XX", "1684MX", "1691MX", "1736MX", "1772MX", "1776MX", "1795MX", "1834MX", "1873MX", "1888XX", "1889MX", "18B2XX", "18E3XX", "18E4MX", "1903MX", "1963XX", "19A4W", "2072W1T2", "2082W1T2", "2093HM", "20B1HM", "20C1DX", "2109W", "2111W", "2123W", "2150DX", "2195W", "2196W", "2199HM", "21A4DX", "2210W", "2238DX", "2249HM", "22F2W", "22T1W", "2310HM", "2313W", "24B7GXT3", "25R8GXT2", "26N2GXT2", "2709HX", "2760GXT2", "2768X", "2788X", "27B2X", "27D9GX", "27Q9GX", "2819X", "2823GX", "2844GX", "2890X", "2895X", "28B2X", "28G1HX", "28K5X", "28Q6X", "28Q9HX", "2903X", "29D7X", "29N1HX", "3007HX", "3046HX", "3227GX", "3228GX"]
#       subject_group = SubjectGroup.find_by_name("sazuka_actigraphy")
#       subjects = subject_group.subjects

#       successful_subjects = []
#       unsuccessful_subjects = []

#       subjects.each do |subject|
#         al = ETL::ActigraphyLoader.new(subject.subject_code, "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/Merged Files", "I:/Projects/Database Project/Data Sources/Actigraphy/Merged Files", true)
#         loaded = al.load_subject

#         if loaded
#           successful_subjects << subject.subject_code
#         else
#           unsuccessful_subjects << subject.subject_code
#         end
#       end

#       LOAD_LOG.info "\n################################\nFinished Loading actigraphy for all Subjects!\nsuccessful: #{successful_subjects}\nunsuccessful: #{unsuccessful_subjects}\n################################\n\n\n"

#     end

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

        pvt_loader = ETL::PvtLoader.new(subject, source, documentation)
        if pvt_loader.load_subject
          successful_subjects << subject
        else
          unsuccessful_subjects << subject
        end
      end

      LOAD_LOG.info "\n################################\nFinished Loading PVT ALL DATA for all Subjects!\nsuccessful: #{successful_subjects.map(&:subject_code)}\nunsuccessful: #{unsuccessful_subjects.map(&:subject_code)}\n################################\n\n\n"
    end

    desc 'load pvt data for Jason - Darpa project'
    task :pvt_all_jason_darpa => :environment do
      successful_subjects = []
      unsuccessful_subjects = []

      sources = [93355756].map{|x| Source.find_by_id x}
      documentation = Documentation.find_by_id 10181

      sources.each do |source|
        pvt_loader = ETL::PvtLoader.new(source.subject, source, documentation)
        if pvt_loader.load_subject
          successful_subjects << source.subject
        else
          unsuccessful_subjects << source.subject
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

    desc 'load t drive location'
    task :t_drive_location => :environment do
      subject_group = SubjectGroup.find_by_name("amu_cleaned")
      LOAD_LOG.info "Loading T Drive Location for #{subject_group.name}"
      res = ETL::TDriveCrawler.populate_t_drive_location(subject_group, "/T/IPM")
      LOAD_LOG.info "T Drive Location Loader Results:\n#{res.to_s}"

    end

    desc "load SH Files"
    task :sh_files => :environment do
      documentation = Documentation.find(93253658)
      subject_group = SubjectGroup.find_by_name("psq_afosr9")

      cr_source = Source.find_by_location("/I/Projects/Database Project/Data Sources/T_DRIVE/S~H Files/#{subject_group.name}_constant_routines.csv")
      lt_source = Source.find_by_location("/I/Projects/Database Project/Data Sources/T_DRIVE/S~H Files/#{subject_group.name}_light_events.csv")
      sp_source = Source.find_by_location("/I/Projects/Database Project/Data Sources/T_DRIVE/S~H Files/#{subject_group.name}_sleep_periods.csv")

      sdl = ETL::SleepDataLoader.new(sp_source, documentation)
      ldl = ETL::LightDataLoader.new(lt_source, documentation)
      cdl = ETL::CrDataLoader.new(cr_source, documentation)

      sdl.load
      ldl.load
      cdl.load

      LOAD_LOG.info "\n################################\nFinished Loading Sleep Data for #{subject_group} Subjects!\n################################\n\n\n"
    end

    desc "load melatonin excel sheets"
    task :melatonin => :environment do
      documentation = Documentation.find()
      subject_group = SubjectGroup.find_by_name("csr_data_request")

      subject_group.subjects.each do |subject|
        base_path = subject.t_drive_location

        Find.find(base_path) do |path|
          #if =~ /
        end

      end
    end

    desc "load admit years"
    task :admit_year => :environment do
      sg = SubjectGroup.find_by_name "amu_cleaned"
      ETL::AdmitYearLoader.populate_admit_year(sg, "/T/IPM")
    end

    desc "load tedious data dictionaries"
    task :pvt_data_dictionaries => :environment do
      Linguistics.use(:en)

      ndt = DataType.find_by_name("numeric_type")
      idt = DataType.find_by_name("integer_type")

      raise StandardError unless (ndt && idt)
      all_dd = []
      (1..10).each do |i|
        all_dd << DataDictionary.create(
            title: "bin_#{i}_mean",
            unit: "milliseconds",
            data_type: ndt,
            description: "**PVT All Column Header:** M#{i}\n\n**Column Description:** MEAN (average) RT for the #{i.en.ordinate} of ten time bins for the given session of PVT. For the standard 10 minute PVT, this bin represents the #{i.en.ordinate} minute of the total session duration.\n\n**Summary:** Mean reaction time for #{i.en.ordinate} minute of 10min PVT."
        )
        all_dd << DataDictionary.create(
            title: "bin_#{i}_mean_of_inverse",
            unit: "milliseconds^-1",
            data_type: ndt,
            description: "**PVT All Column Header:** I#{i}\n\n**Column Description:** The MEAN of the inverse reaction times (1/RT) for the #{i.en.ordinate} of ten time bins for the given session of PVT. For the standard 10 minute PVT, this bin represents the #{i.en.ordinate} minute of the total session duration.\n\n**Summary:** Mean of inverses of reaction times (1/RT) for #{i.en.ordinate} minute of 10min PVT."
        )
        all_dd << DataDictionary.create(
            title: "bin_#{i}_n_trials",
            data_type: idt,
            description: "**PVT All Column Header:** N#{i}\n\n**Column Description:** Number of trials in the #{i.en.ordinate} of ten time bins for the given session of PVT. For the standard 10 minute PVT, this bin represents the #{i.en.ordinate} minute of the total session duration.\n\n**Summary:** Number of trials in the #{i.en.ordinate} minute of 10min PVT."
        )
        all_dd << DataDictionary.create(
            title: "bin_#{i}_n_lapses",
            data_type: idt,
            description: "**PVT All Column Header:** L#{i}\n\n**Column Description:** Number of lapses in the #{i.en.ordinate} of ten time bins for the given session of PVT. For the standard 10 minute PVT, this bin represents the #{i.en.ordinate} minute of the total session duration.\n\n**Summary:** Number of lapses in the #{i.en.ordinate} minute of 10min PVT."
        )
        all_dd << DataDictionary.create(
            title: "bin_#{i}_percent_lapses",
            unit: "percent",
            data_type: ndt,
            description: "**PVT All Column Header:** PL#{i}\n\n**Column Description:** Percent of lapses in the #{i.en.ordinate} of ten time bins for the given session of PVT. For the standard 10 minute PVT, this bin represents the #{i.en.ordinate} minute of the total session duration.\n\n**Summary:** Percent of lapses in the #{i.en.ordinate} minute of 10min PVT."
        )

      end

      ed = EventDictionary.find_by_name('cleaned_pvt_all')
      ed.data_dictionary = ed.data_dictionary + all_dd
      raise StandardError unless ed.valid?

      ed.save

      raise StandardError unless ed.data_dictionary.count > 50


    end

    desc "load column maps for pvts"
    task :pvt_column_maps => :environment do
      yellow_ids = [93355710,93355711,93355712,93355713,93355714,93355715,93355716,93355717,93355718,93355719,93355720,93355721,93355722,93355723,93355724,93355725]
      magenta_ids = [93355726,93355730,93355732,93355739,93355741,93355747,93355749]
      green_ids = [93355703,93355704,93355705,93355706,93355707,93355708,93355709,94635883,94635884]
      blue_ids = [93355729,93355735,93355738,93355744,93355752,93355754,93355756,93355758,93355760]

      yellow_cm =
        [
            { target: :none },
            { target: :none },
            { target: :event, field: :labtime, event_name: 'cleaned_pvt_all' },
            { target: :datum, field: :wake_period, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :test_type_identifier, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :session_number, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :handedness, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :interstimulus_interval_min, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :interstimulus_interval_max, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_coincidence, event_name: 'cleaned_pvt_all' },
            { target: :datum, field: :n_wrong, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_anticipation_wrong, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_anticipation_correct, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_timeouts, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :all_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :all_median, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :all_std, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :slow_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :slow_std, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :fast_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :fast_std, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :all_inverse_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :all_inverse_median, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :all_inverse_std, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_correct, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :slow_inverse_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :slow_inverse_std, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_slow, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :fast_inverse_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :fast_inverse_std, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_fast, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :lapse_transformation, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :n_lapses_in_slow, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :slow_lapse_percentage, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_1_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_2_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_3_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_4_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_5_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_6_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_7_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_8_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_9_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_10_mean, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_1_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_2_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_3_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_4_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_5_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_6_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_7_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_8_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_9_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_10_mean_of_inverse, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_1_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_2_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_3_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_4_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_5_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_6_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_7_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_8_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_9_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_10_n_trials, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_1_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_2_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_3_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_4_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_5_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_6_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_7_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_8_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_9_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_10_n_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_1_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_2_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_3_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_4_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_5_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_6_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_7_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_8_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_9_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :bin_10_percent_lapses, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :slope, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :intercept, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :inverse_of_intercept, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :correlation, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :correlation_squared, event_name: 'cleaned_pvt_all'},
            { target: :event, field: :notes, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :valid_data, event_name: 'cleaned_pvt_all'},
            { target: :none },
            { target: :none },
            { target: :none },
            { target: :datum, field: :include, event_name: 'cleaned_pvt_all'},
            { target: :datum, field: :good, event_name: 'cleaned_pvt_all'}
        ]


      magenta_cm =
          [
              { target: :none },
              { target: :none },
              { target: :event, field: :labtime, event_name: 'cleaned_pvt_all' },
              { target: :none },
              { target: :datum, field: :wake_period, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :test_type_identifier, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :section_of_protocol, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :session_number, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :handedness, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :interstimulus_interval_min, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :interstimulus_interval_max, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_coincidence, event_name: 'cleaned_pvt_all' },
              { target: :datum, field: :n_wrong, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_anticipation_wrong, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_anticipation_correct, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_timeouts, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :all_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :all_median, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :all_std, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :slow_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :slow_std, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :fast_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :fast_std, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :all_inverse_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :all_inverse_median, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :all_inverse_std, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_correct, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :slow_inverse_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :slow_inverse_std, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_slow, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :fast_inverse_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :fast_inverse_std, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_fast, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :lapse_transformation, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :n_lapses_in_slow, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :slow_lapse_percentage, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_1_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_2_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_3_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_4_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_5_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_6_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_7_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_8_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_9_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_10_mean, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_1_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_2_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_3_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_4_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_5_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_6_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_7_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_8_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_9_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_10_mean_of_inverse, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_1_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_2_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_3_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_4_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_5_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_6_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_7_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_8_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_9_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_10_n_trials, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_1_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_2_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_3_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_4_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_5_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_6_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_7_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_8_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_9_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_10_n_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_1_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_2_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_3_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_4_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_5_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_6_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_7_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_8_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_9_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :bin_10_percent_lapses, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :slope, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :intercept, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :inverse_of_intercept, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :correlation, event_name: 'cleaned_pvt_all'},
              { target: :datum, field: :correlation_squared, event_name: 'cleaned_pvt_all'}
          ]

      green_cm =
        [
          { target: :event, field: :labtime, event_name: 'cleaned_pvt_all' },
          { target: :none },
          { target: :none },
          { target: :datum, field: :wake_period, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :test_type_identifier, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :section_of_protocol, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :session_number, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :handedness, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :interstimulus_interval_min, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :interstimulus_interval_max, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_coincidence, event_name: 'cleaned_pvt_all' },
          { target: :datum, field: :n_wrong, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_anticipation_wrong, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_anticipation_correct, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_timeouts, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_median, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :fast_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :fast_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_inverse_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_inverse_median, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_inverse_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_correct, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_inverse_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_inverse_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_slow, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :fast_inverse_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :fast_inverse_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_fast, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :lapse_transformation, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_lapses_in_slow, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_lapse_percentage, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slope, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :intercept, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :inverse_of_intercept, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :correlation, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :correlation_squared, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :test_duration_scheduled, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :test_duration_actual, event_name: 'cleaned_pvt_all'},
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none }
        ]


      blue_cm = [
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :datum, field: :wake_period, event_name: 'pvt_all_analyzed'},
          { target: :datum, field: :test_type_identifier, event_name: 'pvt_all_analyzed'},
          { target: :datum, field: :section_of_protocol, event_name: 'pvt_all_analyzed'},
          { target: :none },
          { target: :event, field: :labtime, event_name: 'pvt_all_analyzed' },
          { target: :datum, field: :session_number, event_name: 'pvt_all_analyzed'}
      ]

      yellow_ids.each do |id|
        #Source.find(id).update_attribute(:column_map, yellow_cm.to_yaml)
      end

      magenta_ids.each do |id|
        #Source.find(id).update_attribute(:column_map, magenta_cm.to_yaml)
      end

      green_ids.each do |id|
        #Source.find(id).update_attribute(:column_map, green_cm.to_yaml)
      end

      blue_ids.each do |id|
        Source.find(id).update_attribute(:column_map, blue_cm.to_yaml)
      end

    end



  end



  namespace :transform do
    desc "merge actigraphy"
    task :merge_actigraphy => :environment do
      subjects = SubjectGroup.find_by_name('actigraphy_lu').subjects
      master_path = "/I/Projects/Database Project/Data Sources/Actigraphy/FD-Actigraphy_2015_03_30.csv"
      output_dir = "/I/Projects/Database Project/Outputs/Actigraphy/dr_lu"

      am = ETL::ActigraphyMerger.new(master_path, output_dir, subjects)
      am.merge_files
    end

    desc "merge sh files"
    task :merge_sh_files => :environment do
      options = {
        source_dir: '/T/IPM',
        output_dir: '/I/Projects/Database Project/Data Sources/T_DRIVE/S~H Files',
        subject_group: SubjectGroup.find_by_name("psq_afosr9"),
        find_missing_t_drive_location: false,
        user_email: "pmankowski@partners.org",
        ignore_duplicates: true
      }

      shm = ETL::ShFileMerger.new(options)
      res = shm.merge
      LOAD_LOG.info "\n\nMerge SH Files Successful!!" if res
    end

    desc "merge Duffy psq files"
    task :merge_duffy_psq_files => :environment do
      destination_file_path = "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/merged_duffy_psqs.csv"
      source_file_list = [
        { source_id: 95375683, column_map: ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'], file_type: :multiple_sheets },
        { source_id: 95375684, column_map: ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'], file_type: :multiple_sheets },
        { source_id: 95375685, column_map: ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'], file_type: :multiple_sheets },
        { source_id: 95375686, column_map: ["subject_code", "sleep_period", "cumulative_minutes", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "person_date_entered", "notes"], file_type: :multiple_sheets },
        { source_id: 95375687, column_map: ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_2a', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'], file_type: :multiple_sheets }
      ]

      psq_merger = ETL::PsqMerger.new nil, source_file_list, destination_file_path
      psq_merger.merge_files
    end

    desc "merge Klerman psq files"
    task :merge_klerman_psq_files => :environment do
      destination_file_path = "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/merged_klerman_psqs.csv"
      source_file_list = [
          { source_id: 95507715, column_map: ['subject_code', 'sleep_period', 'sp_length', 'time_field', 'q_1', 'q_2', 'q_3', 'q_4', 'q_5', 'q_6', 'q_7', 'q_8', 'comments'], file_type: :single_sheet },
          { source_id: 95507716, column_map: ['subject_code', 'sleep_period', 'pre_sp_protocol', 'sp_duration', 'time_field', 'q_1', 'q_2', 'q_3', 'q_4', 'q_5', 'q_6', 'q_7', 'q_8'], file_type: :single_sheet },
          { source_id: 95507717, column_map: ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_2a', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'], file_type: :multiple_sheets }
#          { source_id: 95375703, column_map: ['subject_code', 'time_field', 'q_1', 'q_2', 'q_2a', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'q_9', 'q_10'], file_type: :single_sheet },
      ]

      psq_merger = ETL::PsqMerger.new nil, source_file_list, destination_file_path
      psq_merger.merge_files
    end
  end

  namespace :extract do
    desc "find and extract melatonin files"
    task :melatonin => :environment do
      mf = ETL::MelatoninFinder.new(SubjectGroup.find_by_name("csr_data_request"), "/I/Projects/Database Project/Data Sources/Melatonin")
      mf.extract
    end

    desc "find PVT all files"
    task :pvt_all_files => :environment do
      descriptions = {"darpa_amu_cleaned_afo_missing" => "PVT All cleaned by Dan Cohen according to the Performance Committee Worksheet."} #, "darpa_amu_cleaned_caff" => "PVT All cleaned by James Wyatt according to the Performance Committee Worksheet.", "darpa_modafinil" => "PVT All cleaned by Scott Grady or Daniel Aeschebach"}

      subject_group_list = {SubjectGroup.find_by_name("darpa_amu_cleaned_afo_missing") => "/I/AMU Cleaned Data Sets" }# , SubjectGroup.find_by_name("darpa_amu_cleaned_caff") => "/I/AMU Cleaned Data Sets", SubjectGroup.find_by_name("darpa_modafinil") => "/X/Studies/Analyses/PRET-modafinil/data/cog"}
      output_dir = "/I/Projects/Database Project/Data Sources/PVT_ALL/"
      patterns = {"darpa_amu_cleaned_afo_missing" => /.*testing\/\d[0-9a-z]*[a-z][0-9a-z]*_.*pvt.*fev.*(\.xls)\z/i } #, "darpa_amu_cleaned_caff" => /.*testing\/\d[0-9a-z]*[a-z][0-9a-z]*_.*pvt.*fev.*(\.xls)\z/i, "darpa_modafinil" => /.*pvtall.*(\.xls)\z/i}

      f = ETL::PvtAllFinder.new(subject_group_list, output_dir, descriptions, patterns)
      f.explore
    end

    desc "extract tedious column map for pvt all"
    task :col_map => :environment do
      File.open("/home/pwm4/Desktop/column_mapping_gen.txt", 'w') do |f|
        %w(_mean _mean_of_inverse _n_trials _n_lapses _percent_lapses).each do |suffix|
          (1..10).each do |i|
            f.puts "{target: :datum, field: :bin_#{i}#{suffix}, event_name: 'cleaned_pvt_all'},"
          end
        end

      end
    end

    desc "extract tedious view defs"
    task :view_def => :environment do
      ed = EventDictionary.find_by_name('cleaned_pvt_all')
      query_part = ""

      bin_dd = []
      %w(_mean _mean_of_inverse _n_trials _n_lapses _percent_lapses).each do |p|
        bin_dd += ed.data_dictionary.select {|dd| dd.title =~ /^bin.*#{p}$/} #.sort{|a,b| a.title <=> b.title}
      end

      (ed.data_dictionary - bin_dd).each do |dd|
        query_part += "max( decode(d.title, '#{dd.title}', dv.#{dd.data_type.storage})) #{dd.title},\n"
      end

      bin_dd.each do |dd|
        query_part += "max( decode(d.title, '#{dd.title}', dv.#{dd.data_type.storage})) #{dd.title},\n"
      end

      File.open("/home/pwm4/Desktop/query_part.txt", 'w').write(query_part)
    end
  end

end
