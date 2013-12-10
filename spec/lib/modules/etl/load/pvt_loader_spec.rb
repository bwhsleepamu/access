=begin
File Types for loading for now:

# VPVTALL_<sc>.xls
/home/pwm4/Windows/X/Admin/Committees/Performance Committee/4. IPM Tests-Scales/Tests-Tasks/Psychomotor Vigilance Task (PVT)/PVTALL file header descriptions_New Version.xls

## Overview

## Columns

### Main
- SUBJECT:      Subject subject_code
- REALTIME:     <Only use to compare> <Also, use year!>
- LABTIME:      Event labtime
- CUMHRS:       <Ignore>
- Scheduled:    *other event?? Compare with T drive times?*
- WP:           wake_period
- PROTOCOL:     protocol_section??
- TEST:         test_number??
- SESSION:      session_number
- HAND:         hand
- ISIMIN:       isimin
- ISIMAX:       isimax
- COINC:        coinc
- WRONG:        n_wrong
- ANT_BAD:      ant_bad
- ANT_GOOD:     ant_good
- ISI_FIX_FS:   ???
- RECAL_AA:     ???
- AAGOODCOUN:   ???
- AAGOODMEAN:   ???
- AAGOODSD:     ???
- AABADCOUNT:   ???
- AABADMEAN:    ???
- AABADSD:      ???
- TIMEOUT:      n_timeouts
- ALL_MEAN:     all_mean
- ALL_MED:      all_med
- ALL_STD:      all_std
- SLOW_MEAN:    slow_mean
- SLOW_STD:     slow_std
- FAST_MEAN:    fast_mean
- FAST_STD:     fast_std
- IALL_MEAN:    iall_mean
- IALL_MED:     iall_med
- IALL_STD:     iall_std
- N:            n_correct
- ISLOW_MEAN:   islow_mean
- ISLOW_STD:    islow_std
- ISLOW_N:      islow_n
- IFAST_MEAN:   ...
- IFAST_STD:    ...
- IFAST_N:      ...
- CAL_LAPSES:   ???
- LAPSES:       n_lapses
- LAPSE_TRAN:   ...
- LAPSE_SLOW:   ...
- LAPSE_PERC:   ...
- BIN_MILSEC:   ???
- M1:           m_1..m10
- M2: 
- M3: 
- M4: 
- M5: 
- M6: 
- M7: 
- M8: 
- M9: 
- M10: 
- I1:           i_1..i10
- I2: 
- I3: 
- I4: 
- I5: 
- I6: 
- I7: 
- I8: 
- I9: 
- I10: 
- N1:           n_1..n_10
- N2: 
- N3: 
- N4: 
- N5: 
- N6: 
- N7: 
- N8: 
- N9: 
- N10: 
- L1:           l_1..l_10
- L2: 
- L3: 
- L4: 
- L5: 
- L6: 
- L7: 
- L8: 
- L9: 
- L10: 
- PL1:          pl_1..pl_10
- PL2: 
- PL3: 
- PL4: 
- PL5: 
- PL6: 
- PL7: 
- PL8: 
- PL9: 
- PL10: 
- SLOPE:        slope
- INTERCEPT:    intercept
- I_INTER:      i_intercept
- CORR:         corr
- RSQUARE:      rsquare
- T_DURATION:   t_duration
- T_DUR_ACT:    t_dur_act
- TOT_WARN1:    tot_warn1 ???
- TOT_WARN2:    tot_warn2 ???
- TOT_WARN3:    tot_warn3 ???
- TOT_WRNSTM:   tot_wrnstm ???
- ALERT_TOUT:   alert_tout
- PARM_FILE:    parm_file
- ACK_FILE:     ack_file


- VERSION: 
- Comments
=end
require 'spec_helper'

describe ETL::PvtLoader do
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

    expect(Event.current.count).to eq 218*2
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



