require 'spec_helper'

describe ETL::SleepDataLoader do
  it "should load subjects" do
    source = create(:source, location: '/usr/local/htdocs/access/spec/data/sleep_data_loader/sleep_data.csv')
    documentation = create(:documentation)

    row_count = (%x{wc -l #{source.location}}.split.first.to_i) - 1

    create(:sleep_period_start)
    create(:event_dictionary, name: "sleep_period_end")

    sdl = ETL::SleepDataLoader.new(source, documentation)
    expect(sdl).to be_valid
    expect(sdl.load).to be_true

    expect(Event.count).to eq (row_count * 2)
    expect(Datum.count).to eq (row_count)
    expect(Event.all.map(&:subject).uniq.count).to eq 6

    Event.all.each do |e|
      expect(e.group_label).to be_present
    end

    expect(Event.all.map(&:group_label).uniq.length).to eq(row_count)

    expect(source.events.count).to eq (row_count * 2)

    expect(sdl.load).to be_true
    expect(Event.count).to eq (row_count * 2)
  end
end
