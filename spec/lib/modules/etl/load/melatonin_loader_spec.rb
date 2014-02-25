require 'spec_helper'

describe ETL::PvtLoader do
  describe "initialization" do

  end

  describe "loading" do
    it "should load events into database" do
      @test_subject = create(:subject, subject_code: "3315GX32", admit_date: Time.zone.local(2013, 7, 23))

    end
  end
end



before do
  @test_subject = create(:subject, subject_code: "24B7GXT3")

  @st = create(:source_type, name: "Excel File")
  @d = create(:documentation, title: "Loading of merged melatonin data")
  @s = create(:source, location: "/usr/local/htdocs/access/spec/data/melatonin_loader/24B7GXT2_MEL.xls", source_type: @st)
  create(:user, email: "pmankowski@partners.org")

  @ed1 = create(:scored_pvt)
  @ed2 = create(:scheduled_pvt)

  @pvt_loader = ETL::PvtLoader.new(@test_subject, @s, @d)
end

it "should load events into database" do
  expect(@pvt_loader).to be_valid

  result = @pvt_loader.load_subject
  expect(result).to be_true

  expect(Event.current.count).to eq 218
  expect(Event.where(name: @ed1.name).count).to eq 218

  test_event = Event.where(name: @ed1.name)[30]
  expect(test_event.data.length).to be > 0
  expect(test_event.data.length).to eq @ed1.data_dictionary.length
  test_event.data.each do |d|
    expect(d.value).to be_present
  end

  expect(test_event.documentation).to eq @d
  expect(test_event.source).to eq @s
  expect(test_event.subject).to eq @test_subject
end

