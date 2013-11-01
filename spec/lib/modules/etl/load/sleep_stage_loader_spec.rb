require 'spec_helper'

describe ETL::SleepStageLoader do
  before do
    test_subject = "3232GX"

    @st = create(:source_type, name: "<SUBJECT_CODE>Slp.01.csv")
    @d = create(:documentation, title: "Loading of Sleep Stage Information")
    create(:user, email: "pmankowski@partners.org")

    int_type = create(:integer_type)
    num_type = create(:numeric_type)
    data_dictionaries = [
      create(:data_dictionary, title: "scored_stage", data_type: int_type),
      create(:data_dictionary, title: "epoch_length", data_type: num_type),
      create(:data_dictionary, title: "sleep_wake_period", data_type: int_type)
    ]

    Event.create

    ed = build(:event_dictionary, name: "scored_epoch")
    ed.data_dictionary = data_dictionaries
    ed.save

    parent_path = "/usr/local/htdocs/access/spec/data"
    @location = "/usr/local/htdocs/access/spec/data"

    @ssl = ETL::SleepStageLoader.new(test_subject, parent_path, @location)

  end

  it "should load events into database" do    
    res = @ssl.load_subject
    res.should == true

    Event.all.count.should == 200
    Event.first.data.length.should == 3
    Event.first.data.first.data_values.length.should == 1
    expect(Event.first.subject.subject_code).to eq "3232GX"

    #3232GX, 1, 7079.347500, 5
    e = Event.order(:realtime)[183]
    expect(e.realtime).not_to be_nil
    expect(e.labtime).not_to be_nil
    expect(e.labtime.to_time).to eq(e.realtime)
    expect(e.datum(:sleep_wake_period).value).to eq(1)
    expect(e.datum(:scored_stage).value).to eq(5)
    expect(e.datum(:epoch_length).value).to eq(30)

    expect(e.source.location).to include(@location)
    expect(e.source.source_type).to eq(@st)

    expect(e.documentation).to eq(@d)
  end

  it "should override any events in the database for the current subject" do
    @ssl.load_subject
    Event.all.count.should == 200
    @ssl.load_subject
    Event.all.count.should == 200
  end  
end
