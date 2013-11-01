require 'spec_helper'

describe ETL::DatabaseLoader do
  let(:data_info) {
    {
        path: "spec/data/fd_subjects.xls",
        header: true,
        skip_lines: 1,
    }
  }

  let (:conditional_data_info) {
    {
        path: "spec/data/fd_subjects_conditional.xls",
        header: true,
        skip_lines: 1,
    }
  }

  let(:dbf_data_info) {
    {
        path: "spec/data/dbf_file_test.dbf",
        header: true,
        first_line: 44,
        last_line: 200
    }
  }

  let(:dbf_column_map) {
    [
      {
        target: :event,
        field: :labtime,
        labtime_fn: "from_s"
      },
      {
        target: :event,
        field: :labtime_sec
      }

    ]

  }


  let(:dbf_object_map) {
    [
      {
        class: Event,
        existing_records: {action: :update, find_by: [:name, :subject_id]},
        event_name: :forced_desynchrony_subject_information,
        static_fields: {realtime: Time.zone.now}
      },
      {
        class: Event,
        existing_records: {action: :update, find_by: [:name, :subject_id]},
        event_name: :forced_desynchrony_subject_information,
        static_fields: {realtime: Time.zone.now}
      },
    ]
  }

  let(:row_count) {7}
  let(:column_map) {
    [
      {
        target: :subject,
        field: :subject_code,
      },
      {
        target: :subject,
        field: :t_drive_location
      },
      {
        target: :study,
        field: :official_name,
        definitive: true
      },
      {
        target: :study,
        field: :nicknames
      },
      {
        target: :irb,
        field: :title,
        multiple: true
      },
      {
        target: :irb,
        field: :number,
        multiple: true,
      },
      {
        target: :researcher,
        field: :full_name,
        definitive: :true,
        researcher_type: :pi,
        multiple: true
      },
      {
        target: :researcher,
        field: :full_name,
        researcher_type: :pl,
        role: :original
      },
      {
        target: :researcher,
        field: :full_name,
        researcher_type: :pl,
        role: :current
      },
      {
        target: :subject,
        field: :admit_date
      },
      {
        target: :subject,
        field: :discharge_date
      },
      {
        target: :subject,
        field: :disempanelled
      },
      {
        target: :subject,
        field: :notes
      },      
      {
        target: :datum,
        field: :age_group,
        event_name: :forced_desynchrony_subject_information
      },
      {
        target: :datum,
        field: :t_cycle,
        event_name: :forced_desynchrony_subject_information
      },
      {
        target: :datum,
        field: :sleep_period_duration,
        event_name: :forced_desynchrony_subject_information
      },
      {
        target: :datum,
        field: :wake_period_duration,
        event_name: :forced_desynchrony_subject_information
      },
      {
          target: :datum,
          field: :analysis_start_time,
          event_name: :forced_desynchrony_subject_information
      },
      {
          target: :datum,
          field: :analysis_end_time,
          event_name: :forced_desynchrony_subject_information
      },
      {
          target: :datum,
          field: :intervention,
          event_name: :forced_desynchrony_subject_information
      }

    ]
  } 
  let(:object_map) {
    [
      {
        class: Subject,
        existing_records: {action: :update, find_by: [:subject_code]}
      },
      {
        class: Study,
        existing_records: {action: :update, find_by: [:official_name]}
      },
      {
        class: Researcher,
        existing_records: {action: :update, find_by: [:full_name]},
        researcher_type: :pi
      },
      {
        class: Researcher,
        existing_records: {action: :update, find_by: [:full_name]},
        researcher_type: :pl,
        role: :original
      },
      {
        class: Researcher,
        existing_records: {action: :update, find_by: [:full_name]},
        researcher_type: :pl,
        role: :current
      },
      {
        class: Irb,
        existing_records: {action: :update, find_by: [:number]}
      },
      {
        class: Event,
        existing_records: {action: :update, find_by: [:name, :subject_id]},
        event_name: :forced_desynchrony_subject_information,
        static_fields: {realtime: Time.zone.now}
      }
    ]
  }


  let(:destroy_object_map) {
    [
        {
            class: Subject,
            existing_records: {action: :update, find_by: [:subject_code]}
        },
        {
            class: Study,
            existing_records: {action: :update, find_by: [:official_name]}
        },
        {
            class: Researcher,
            existing_records: {action: :update, find_by: [:full_name]},
            researcher_type: :pi
        },
        {
            class: Researcher,
            existing_records: {action: :update, find_by: [:full_name]},
            researcher_type: :pl,
            role: :original
        },
        {
            class: Researcher,
            existing_records: {action: :update, find_by: [:full_name]},
            researcher_type: :pl,
            role: :current
        },
        {
            class: Irb,
            existing_records: {action: :update, find_by: [:number]}
        },
        {
            class: Event,
            existing_records: {action: :destroy, find_by: [:name, :subject_id]},
            event_name: :forced_desynchrony_subject_information,
            static_fields: {realtime: Time.zone.now}
        }
    ]
  }

  let(:source) { create(:source) }
  let(:documentation) { create(:documentation) }
  
  describe "#initialize" do
    before do
      create(:forced_desynchrony_subject_information)
      @db_loader = ETL::DatabaseLoader.new(data_info, object_map, column_map, source, documentation)
    end

    it "should generate mapping for use by loader from column map input" do
      lm = @db_loader.instance_eval{ @loader_map }
      lm.should be_present
      lm.length.should == object_map.length
      lm.each do |mapping|
        mapping.should have_key :column_fields
        mapping.should have_key :class
        mapping.should have_key :existing_records
        mapping[:column_fields].each do |key, value|
          key.should be_present
          value.should be_present
        end
      end

    end

    it "should open data file and allow it to be read" do
      @db_loader.source_file.class.should == Roo::Excel
    end
  end

  describe "#load_file" do
    before do
      create(:forced_desynchrony_subject_information)

      @db_loader = ETL::DatabaseLoader.new(data_info, object_map, column_map, source, documentation)
      @db_loader.load_data
    end

    it "should load the data from the file to the database" do

      Subject.count.should == row_count
      Irb.count.should == 1
      Researcher.count.should == 4
      Event.count.should == row_count - 1
      Study.count.should == 1

      s = Subject.find_by_subject_code("3232GX")
      s.admit_date.month.should == 10
      s.should be_present
      s.irbs.length.should == 1
      s.irbs.first.title.should == "Sleep duration required to restore performance during chronic sleep restriction"
      s.irbs.first.number.should == "2011-P-001094"
      s.project_leaders.length.should == 2
      s.project_leaders.first.last_name.should == "Hull"
      s.principal_investigators.length.should == 1
      s.principal_investigators.first.last_name.should == "Klerman"
      s.study.official_name.should == "Sleep duration required to restore performance during chronic sleep restriction"
      s.events.length.should == 1
      s.events.first.data.where(title: "age_group").first.value.should == "young"

      [Subject, Irb, Researcher, Study, Event, Datum, DataValue].each do |cls|
        MY_LOG.info "### #{cls} ###"
        MY_LOG.info cls.first.attributes.slice(*cls.attribute_names + ["id", "text_value", "num_value", "time_value"])
        MY_LOG.info "###\n"
      end

    end

    it "should not duplicate objects on multiple file loads" do

      before_counts = {subjects: Subject.count, studies: Study.count, publications: Publication.count, irbs: Irb.count, researchers: Researcher.count, events: Event.count, data: Datum.count, data_values: DataValue.count}
      @db_loader.load_data
      after_counts = {subjects: Subject.count, studies: Study.count, publications: Publication.count, irbs: Irb.count, researchers: Researcher.count, events: Event.count, data: Datum.count, data_values: DataValue.count}

      MY_LOG.info "#{before_counts}\n#{after_counts}"
      before_counts.should == after_counts
    end

    it "should not load empty objects or events" do
      s = Subject.find_by_subject_code("3200TX")
      s.principal_investigators.should be_empty
      s = Subject.find_by_subject_code("3201TX")
      s.events.should be_empty
    end

    it "should load multiple principal_investigators" do
      s = Subject.find_by_subject_code("3201TX")
      s.principal_investigators.length.should == 2

    end

    it "should load original and current project leaders" do
      s1 = Subject.find_by_subject_code("3200TX")
      s2 = Subject.find_by_subject_code("3201TX")


      s1.subjects_project_leaders.length.should == 2
      s1.project_leaders.length.should == 2
      s1.project_leaders.uniq.length.should == 1


      MY_LOG.info "s1: #{s1.project_leaders}"
      MY_LOG.info "s2: #{s2.project_leaders}"

      s2.project_leader("original").last_name.should == "Hull"
      s2.project_leader("current").last_name.should == "Mankowski"
    end

  end

  describe "destroying objects" do
    before do
      create(:forced_desynchrony_subject_information)

      @db_loader = ETL::DatabaseLoader.new(data_info, destroy_object_map, column_map, source, documentation)
      @db_loader.load_data
    end

    it "should load the data from the file to the database" do

      Subject.count.should == row_count
      Irb.count.should == 1
      Researcher.count.should == 4
      Event.count.should == row_count - 1
      Study.count.should == 1

      s = Subject.find_by_subject_code("3232GX")
      s.admit_date.month.should == 10
      s.should be_present
      s.irbs.length.should == 1
      s.irbs.first.title.should == "Sleep duration required to restore performance during chronic sleep restriction"
      s.irbs.first.number.should == "2011-P-001094"
      s.project_leaders.length.should == 2
      s.project_leaders.first.last_name.should == "Hull"
      s.principal_investigators.length.should == 1
      s.principal_investigators.first.last_name.should == "Klerman"
      s.study.official_name.should == "Sleep duration required to restore performance during chronic sleep restriction"
      s.events.length.should == 1
      s.events.first.data.where(title: "age_group").first.value.should == "young"

      [Subject, Irb, Researcher, Study, Event, Datum, DataValue].each do |cls|
        MY_LOG.info "### #{cls} ###"
        MY_LOG.info cls.first.attributes.slice(*cls.attribute_names + ["id", "text_value", "num_value", "time_value"])
        MY_LOG.info "###\n"
      end

    end

    it "should not duplicate objects on multiple file loads" do

      before_counts = {subjects: Subject.count, studies: Study.count, publications: Publication.count, irbs: Irb.count, researchers: Researcher.count, events: Event.count, data: Datum.count, data_values: DataValue.count}
      @db_loader.load_data
      after_counts = {subjects: Subject.count, studies: Study.count, publications: Publication.count, irbs: Irb.count, researchers: Researcher.count, events: Event.count, data: Datum.count, data_values: DataValue.count}

      MY_LOG.info "#{before_counts}\n#{after_counts}"
      before_counts.should == after_counts
    end

  end

  describe "New Additions" do
    before do
      create(:forced_desynchrony_subject_information)

      @data_info = data_info
      @column_map = column_map
      @object_map = object_map

      @data_info[:path] = "spec/data/fd_subjects_conditional.xls"

      @column_map.last[:conditions] = "['CSR', 'CONTROL'].include?(field)"

      @object_map.last[:static_fields] = {labtime_year: 2005}

      @column_map << {
          target: :event,
          field: :labtime,
          event_name: :forced_desynchrony_subject_information,
          labtime_fn: "from_s",
          conditions: "field.present?"
      }




    end
    describe "Conditional Loading" do

      it "should allow the rows to be loaded to be limited to only a given part of the file" do
        pending
      end

      it "should allow conditional loading of a row depending on a column's value" do
        db_loader = ETL::DatabaseLoader.new(@data_info, @object_map, @column_map, source, documentation)
        db_loader.load_data

        Subject.count.should == 4
      end
    end

    describe "Reading in real times and labtimes for events" do
      it "should read in realtimes from a string of a given format" do
        pending
      end

      it "should read in a labtime in string format and initialize it using a given function name" do
        pending
      end
    end
  end



end

