require 'spec_helper'

describe ETL::SleepStageLoader do
  before do
    subjects = []
    subjects << create(:subject, subject_code: '23D8HS', admit_year: 2003)
    #subjects << create(:subject, subject_code: '28J8X', admit_year: 2008)
    #subjects << create(:subject, subject_code: '2632DX', admit_year: 2006)
    #subjects << create(:subject, subject_code: '3335GX', admit_year: 2013)

    @sg = create(:subject_group)
    @sg.subjects = subjects

    @sg.save


    @st = create(:source_type, name: "AMU Cleaned Sleep Stage File")
    @d = create(:documentation, title: "Loading of Sleep Stage Information")

    @u = create(:user, email: "pmankowski@partners.org")

    int_type = create(:integer_type)
    num_type = create(:numeric_type)
    data_dictionaries = [
      create(:data_dictionary, title: "scored_stage", data_type: int_type),
      create(:data_dictionary, title: "epoch_length", data_type: num_type),
      create(:data_dictionary, title: "sleep_wake_period", data_type: int_type)
    ]

    ed = build(:event_dictionary, name: "scored_epoch")
    ed.data_dictionary = data_dictionaries
    ed.save

    @root_path = "/usr/local/htdocs/access/spec/data/sleep_stage_loader/AMU"
  end

  it "should load events into database" do    
    ssl = ETL::SleepStageLoader.new(@root_path, @sg, @st, @d, @u)

    result = ssl.load

    expect(result[:loaded].length).to eq(@sg.subjects.length)

    expect(Event.all.count).to eq(200*@sg.subjects.length)

    @sg.subjects.each do |subject|
      MY_LOG.info "events: #{subject.events.count}"
      expect(subject.events.count).to be >= 200
    end

=begin
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
=end
  end

  it "should override any events in the database for the current subject" do
    @ssl.load_subject
    Event.all.count.should == 200
    @ssl.load_subject
    Event.all.count.should == 200
  end  
end
