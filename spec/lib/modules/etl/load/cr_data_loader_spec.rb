require 'spec_helper'

describe ETL::CrDataLoader do
  it "should load subjects" do
    source = create(:source, location: '/usr/local/htdocs/access/spec/data/cr_data_loader/cr_data.csv')
    documentation = create(:documentation)

    row_count = (%x{wc -l #{source.location}}.split.first.to_i) - 1

    create(:constant_routine_start)
    create(:event_dictionary, name: "constant_routine_end")

    cdl = ETL::CrDataLoader.new(source, documentation)
    expect(cdl).to be_valid
    expect(cdl.load).to be_true

    expect(Event.count).to eq (row_count * 2)
    expect(Datum.count).to eq (row_count)
    expect(Event.all.map(&:subject).uniq.count).to eq 6


    Event.all.each do |e|
      expect(e.group_label).to be_present
    end

    expect(Event.all.map(&:group_label).uniq.length).to eq(row_count)

    expect(source.events.count).to eq (row_count * 2)

    expect(cdl.load).to be_true
    expect(Event.count).to eq (row_count * 2)
  end
end
