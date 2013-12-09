=begin
  Sources will be the original files
  Documentation - PSQ Master File??
=end




module ETL
  class PvtLoader
    EVENT_NAME = 'scored_pvt'
    SCHEDULED_EVENT_NAME = 'scheduled_pvt'


    def initialize(subject_group, source, documentation)


    end





    private

    def init_column_map
=begin

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




      @column_map = [
          { target: :subject, field: :subject_code },
          { target: :event, field: :realtime, event_name: EVENT_NAME },
          { target: :event, field: :labtime, event_name: EVENT_NAME },
          { target: :none },
          { target: :event, field: :labtime, event_name: SCHEDULED_EVENT_NAME },
          { taget: :datum, field: :wake_period, event_name: EVENT_NAME},
          { taget: :datum, field: :section_of_protocol, event_name: EVENT_NAME},
          { taget: :datum, field: :test_number, event_name: EVENT_NAME},
          { taget: :datum, field: :session_number, event_name: EVENT_NAME},
          { taget: :datum, field: :hand, event_name: EVENT_NAME},
          { taget: :datum, field: :wake_period, event_name: EVENT_NAME},
          { taget: :datum, field: :wake_period, event_name: EVENT_NAME},

          { target: :event, field: :labtime },
          { target: :irb, field: :title, multiple: true },
          { target: :irb, field: :number, multiple: true },
          { target: :researcher, field: :full_name, researcher_type: :pi, multiple: true },
          { target: :researcher, field: :full_name, researcher_type: :pl, role: :original },
          { target: :researcher, field: :full_name, researcher_type: :pl, role: :current },
          { target: :subject, field: :admit_date },
          { target: :subject, field: :discharge_date },
          { target: :subject, field: :disempanelled },
          { target: :subject, field: :notes }
      ]



      column_map = [
          { target: :none },
          { target: :none },
          { target: :event, field: :labtime_year, event_name: EVENT_NAME.to_sym },
          { target: :event, field: :labtime_hour, event_name: EVENT_NAME.to_sym },
          { target: :event, field: :labtime_min, event_name: EVENT_NAME.to_sym },
          { target: :event, field: :labtime_sec, event_name: EVENT_NAME.to_sym },
          { target: :datum, field: :activity_count, event_name: EVENT_NAME.to_sym },
          { target: :datum, field: :light_level, event_name: EVENT_NAME.to_sym },
          { target: :datum, field: :epoch_length, event_name: EVENT_NAME.to_sym }
      ]

      object_map = [
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: EVENT_NAME.to_sym
          }
      ]




    end

    def init_object_map
      @object_map = [
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
          }
      ]
    end



  end
end





def init_fd_subjects
  @column_map += [
      { target: :datum, field: :age_group, event_name: :forced_desynchrony_subject_information },
      { target: :datum, field: :t_cycle, event_name: :forced_desynchrony_subject_information },
      { target: :datum, field: :sleep_period_duration, event_name: :forced_desynchrony_subject_information },
      { target: :datum, field: :wake_period_duration, event_name: :forced_desynchrony_subject_information },
      { target: :datum, field: :analysis_start_time, event_name: :forced_desynchrony_subject_information },
      { target: :datum, field: :analysis_end_time, event_name: :forced_desynchrony_subject_information },
      { target: :datum, field: :intervention, event_name: :forced_desynchrony_subject_information }
  ]

  @object_map += [
      {
          class: Event,
          existing_records: {action: :destroy, find_by: [:name, :subject_id]},
          event_name: :forced_desynchrony_subject_information,
          static_fields: {realtime: Time.zone.now}
      }
  ]
end

