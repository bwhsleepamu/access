require 'spec_helper'
require 'csv'
#require 'fakefs/spec_helpers'



describe ETL::ActigraphyLoader do
  describe "main workflow" do
    before do
      create :actigraphy_measurement
      create :user, email: ETL::ActigraphyLoader::USER_EMAIL
      @st = create :source_type, name: ETL::ActigraphyLoader::SOURCE_TYPE_NAME
      @d = create :documentation, title: ETL::ActigraphyLoader::DOC_TITLE
      @subjects = %w(24B7GXT3)
    end
    it "should load events from merged actigraphy file" do

      @subjects.each do |subject|
        al = ETL::ActigraphyLoader.new(subject, "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/Merged Files/.example", "I:/Projects/Database Project/Data Sources/Actigraphy/Merged Files")
        al.load_subject
      end

      MY_LOG.info "SUBJECTS: #{Subject.all}"

      Subject.all.length.should == @subjects.length
      Event.count.should == 1000
      Datum.count.should == 3000

      e = Event.where(labtime_hour: 5074, labtime_min: 58, labtime_sec: 0, labtime_year: 2007).first

      e.documentation.should == @d
      e.source.source_type.should == @st
      e.source.location.should == "I:/Projects/Database Project/Data Sources/Actigraphy/Merged Files/24B7GXT3.csv"
      e.source.notes.length.should > 10

      e.labtime.should == Labtime.new(2007, 5074, 58, 0)
      e.realtime.should_not be_nil
      e.name.should == "actigraphy_measurement"

      e.data.where(title: "activity_count").first.value.should == 352
      e.data.where(title: "epoch_length").first.value.should == 60
      #e.data.where(title: "light_level").first.data_values.first.num_value.should == 11.4
    end

    it "should not duplicate objects" do
      al = ETL::ActigraphyLoader.new(@subjects.first, "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/Merged Files/.example", "I:/Projects/Database Project/Data Sources/Actigraphy/Merged Files")
      al.load_subject

      count = {subject: Subject.count, event: Event.count, source: Source.count }
      count.values.each { |val| val.should > 0 }

      al = ETL::ActigraphyLoader.new(@subjects.first, "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/Actigraphy/Merged Files/.example", "I:/Projects/Database Project/Data Sources/Actigraphy/Merged Files")
      al.load_subject

      { subject: Subject.count, event: Event.count, source: Source.count }.should == count


    end
  end
end