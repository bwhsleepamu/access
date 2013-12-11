=begin
File Types for loading for now:

# SCALES_<sc>.xls  (scalesad) (mood)  (SCALESAD.TST)
## Overview

## Columns

### --> Event Labtime
- LABTIME
- SECONDS

### --> (Not Needed - possible to check conversion)
- DATE
- TIME

### --> Subject Subject code
- SUBJECT

## Another labtime??
- LABTIME
- CUMHRS

### Scheduled Labtime - keep?
- Scheduled

### Wake Period
- WP

### Type of Protocol
- PROTOCOL

### Test # or type
- TEST

### Session #
- SESSION

### Testing variables
- ALERT       sleepy_alert
- CALM        excited_calm
- STRONG      weak_strong
- CLEARHEADE  groggy_clearheaded
- WELLCOORDI  clumsy_wellcoordinated
- ENERGETIC   sluggish_energetic
- CONTENTED   discontented_contented
- TRANQUIL    troubled_tranquil
- QUICKWITTE  mentallyslow_quickwitted
- RELAXED     tense_relaxed
- ATTENTIVE   dreamy_attentive
- COMPETENT   incompetent_competent
- SAD         happy_sad
- FRIENDLY    hostile_friendly
- INTERESTED  bored_interested
- SOCIABLE    withdrawn_sociable
- WARM        cold_warm

### Test version
- VERSION

### Comments
- Comments


# SScales_<sc>.xls   (shtscale)  (mood scales short) (smood) (SHTSCALE.TST)
## Overview

## Columns

### Same as in full length mood
- LABTIME
- SECONDS
- DATE
- TIME
- SUBJECT
- LABTIME
- CUMHRS
- Scheduled
- WP
- PROTOCOL
- TEST
- SESSION


- ALERT       sleepy_alert
- SAD         happy_sad
- CALM        excited_calm

### Same as in full length mood
- VERSION
- Comments



=end



require 'spec_helper'

describe ETL::VasLoader do
  before do
    @test_subject = create(:subject, subject_code: "3335GX", admit_date: Time.zone.local(2013, 6, 24))

    @st = create(:source_type, name: "Excel File")
    @d = create(:documentation, title: "Loading of VAS Data")
    @s = create(:source, location: "/usr/local/htdocs/access/spec/data/vas_loader/scales_test.xls", source_type: @st)
    @ss = create(:source, location: "/usr/local/htdocs/access/spec/data/vas_loader/sscales_test.xls", source_type: @st)

    create(:user, email: "pmankowski@partners.org")

  end

  it "should load scalesad events into database" do
    @ed1 = create(:vas_scalesad_cleaned)
    @ed3 = create(:vas_scalesad_scheduled)

    @vas_loader = ETL::VasLoader.new(@test_subject, @s, @d, 'vas_scalesad')

    test_loading(@vas_loader, 218, @ed1, @s)
  end

  it "should override any events in the database for the current subject" do
    @ed1 = create(:vas_scalesad_cleaned)
    @ed3 = create(:vas_scalesad_scheduled)
    @vas_loader = ETL::VasLoader.new(@test_subject, @s, @d, 'vas_scalesad')

    @vas_loader.load_subject

    expect { @vas_loader.load_subject }.not_to change { Event.count }
  end

  it 'should load shtscale events into database' do
    @ed2 = create(:vas_shtscale_cleaned)
    @ed4 = create(:vas_shtscale_scheduled)
    @vas_loader = ETL::VasLoader.new(@test_subject, @ss, @d, 'vas_shtscale')

    test_loading(@vas_loader, 66, @ed2, @ss)
  end


  def test_loading(vas_loader, event_count, ed, s)
    expect(vas_loader).to be_valid

    result = vas_loader.load_subject
    expect(result).to be_true

    expect(Event.current.count).to eq event_count*2
    expect(Event.where(name: ed.name).count).to eq event_count

    test_event = Event.where(name: ed.name)[30]
    expect(test_event.data.length).to be > 0
    expect(test_event.data.length).to eq ed.data_dictionary.length
    test_event.data.each do |d|
      expect(d.value).to be_present
    end

    expect(test_event.documentation).to eq @d
    expect(test_event.source).to eq s
    expect(test_event.subject).to eq @test_subject
  end
end
