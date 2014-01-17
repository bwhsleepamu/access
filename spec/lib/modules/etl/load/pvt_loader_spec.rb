require 'spec_helper'

describe ETL::PvtLoader do
  describe "Joe Hull PVT All" do
    before do
      @test_subject = create(:subject, subject_code: "3315GX32", admit_date: Time.zone.local(2013, 7, 23))

      @st = create(:source_type, name: "VPVTALL XLS")
      @d = create(:documentation, title: "Loading of scored PVT Data")
      @s = create(:source, location: "/usr/local/htdocs/access/spec/data/pvt_loader/vpvt_all.xls", source_type: @st)
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

    it "should override any events in the database for the current subject" do
      @pvt_loader.load_subject

      expect { @pvt_loader.load_subject }.not_to change { Event.count }
    end
  end

  it "should work with column maps and worksheet names from the database" do
    s = create(:subject, subject_code: "24B7GXT3", admit_year: 2007)
    d = create(:documentation, title: "Loading of scored PVT Data")
    st = create(:source_type, name: "VPVTALL XLS")
    sr = create(:source, location: "/usr/local/htdocs/access/spec/data/pvt_loader/24B7GXT3_PVT_fev.xls", source_type: @st, worksheet_name: 'acceptable', column_map: "---\n- :target: :event\n  :field: :labtime\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :none\n- :target: :datum\n  :field: :wake_period\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :test_type_identifier\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :section_of_protocol\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :session_number\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :handedness\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :interstimulus_interval_min\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :interstimulus_interval_max\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :n_coincidence\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :n_wrong\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :n_anticipation_wrong\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :n_anticipation_correct\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :n_timeouts\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :all_mean\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :all_median\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :all_std\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :slow_mean\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :slow_std\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :fast_mean\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :fast_std\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :datum\n  :field: :n_correct\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :datum\n  :field: :n_lapses\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :lapse_transformation\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :n_lapses_in_slow\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :datum\n  :field: :slope\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :intercept\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :datum\n  :field: :correlation\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :datum\n  :field: :test_duration_scheduled\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :test_duration_actual\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :event\n  :field: :notes\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :datum\n  :field: :valid_data\n  :event_name: 'cleaned_pvt_all'\n- :target: :none\n- :target: :none\n- :target: :none\n- :target: :datum\n  :field: :include\n  :event_name: 'cleaned_pvt_all'\n- :target: :datum\n  :field: :good\n  :event_name: 'cleaned_pvt_all'\n" )
    create(:user, email: "pmankowski@partners.org")

    ed = create(:scored_pvt)

    pvt_loader = ETL::PvtLoader.new(s, sr, d)

    expect(pvt_loader).to be_valid

    result = pvt_loader.load_subject
    expect(result).to be_true

    expect(Event.current.count).to be >= 2


  end
end



