namespace :temp do
  namespace :load do

    desc "load temp subjects"
    task :subjects => :environment do
      sg = SubjectGroup.create(name: "beth_raster_plots")

      CSV.foreach("/home/pwm4/Desktop/GRRRR/Vacation Data/subjects.csv") do |line|
        s = Subject.new(subject_code: line[0], admit_year: line[1])
        s.save
        sg.subjects << s
      end
      sg.save
    end


    desc "load sleep light"
    task :sleep_light => :environment do
      doc = Documentation.find(112)
      #sg = SubjectGroup.find_by_name("beth_raster_plots")

      s1 = Source.find_or_create_by(location: "/home/pwm4/Desktop/GRRRR/Vacation Data/Merged/sleep_periods.csv")
      s2 = Source.find_or_create_by(location: "/home/pwm4/Desktop/GRRRR/Vacation Data/Merged/light_events.csv")

      sdl = ETL::SleepDataLoader.new(s1, doc)
      ll = ETL::LightDataLoader.new(s2, doc)

      sdl.load
      ll.load
    end
  end
end
