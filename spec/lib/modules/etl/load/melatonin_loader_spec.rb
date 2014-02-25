require 'spec_helper'

describe ETL::MelatoninLoader do

  before do
    @test_subject = create(:subject, subject_code: "24B7GXT3")

    @st = create(:source_type, name: "Excel File")
    @d = create(:documentation, title: "Loading of merged melatonin data")
    @s = create(:source, location: "/usr/local/htdocs/access/spec/data/melatonin_loader/24B7GXT2_MEL.xls", source_type: @st)
    create(:user, email: "pmankowski@partners.org")

    @ed = create(:melatonin_sample)

    @mel_loader = ETL::MelatoninLoader.new(@test_subject, @s, @d)
  end

  it "should load events into database" do
    expect(@mel_loader).to be_valid

    result = @mel_loader.load_subject
    expect(result).to be_true

    expect(Event.current.count).to eq 576

    test_event = Event.where(name: @ed.name)[30]
    expect(test_event.data.length).to be > 0
    expect(test_event.data.length).to eq @ed.data_dictionary.length
    test_event.data.each do |d|
      expect(d.value).to be_present
    end

    expect(test_event.documentation).to eq @d
    expect(test_event.source).to eq @s
    expect(test_event.subject).to eq @test_subject
  end

end



