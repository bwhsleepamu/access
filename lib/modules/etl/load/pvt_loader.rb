=begin
  Sources will be the original files
  Documentation - PSQ Master File??
=end



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

module ETL
  class PvtLoader
    EVENT_NAME = 'cleaned_pvt_all'
    SCHEDULED_EVENT_NAME = 'scheduled_pvt_all'
    SOURCE_SHEET = "FEV"


    def initialize(subject, source, documentation)
      begin
        @subject = subject
        admit_year = subject.admit_year
        input_file_info = { path: source.location, sheet: source.worksheet_name, skip_lines: 1 }

        col_map_to_use = source.column_map.present? ? YAML.load(source.column_map) : column_map

        @db_loader = ETL::DatabaseLoader.new(input_file_info, analyzed_object_map(admit_year), col_map_to_use, source, documentation, @subject, false)
        LOAD_LOG.info "#### PVT Loader: Successfully initialized #{@subject.subject_code} for loading of PVT data"
        @valid = true
      rescue => error
        LOAD_LOG.info "#### PVT Loader: Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
        @valid = false
      end
    end

    def valid?
      @valid
    end

    def load_subject
      if @valid
        loaded = false
        begin
          LOAD_LOG.info "######################             PVT LOADER            #######################"
          LOAD_LOG.info "###################### Starting #{@subject.subject_code} #######################"
          loaded = @db_loader.load_data
        rescue => error
          LOAD_LOG.info "#### Load Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}\n\n"
        end
        loaded
      else
        false
      end
    end

    private

    def standard_col_map
      # These are the largely standardized PVT all columns
      [
          { target: :datum, field: :session_number, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :handedness, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :interstimulus_interval_min, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :interstimulus_interval_max, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_coincidence, event_name: 'cleaned_pvt_all' },
          { target: :datum, field: :n_wrong, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_anticipation_wrong, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_anticipation_correct, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_timeouts, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_median, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :fast_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :fast_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_inverse_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_inverse_median, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :all_inverse_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_correct, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_inverse_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_inverse_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_slow, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :fast_inverse_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :fast_inverse_std, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_fast, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :lapse_transformation, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :n_lapses_in_slow, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slow_lapse_percentage, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_mean, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_mean_of_inverse, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_n_trials, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_n_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_1_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_2_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_3_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_4_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_5_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_6_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_7_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_8_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_9_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :bin_10_percent_lapses, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :slope, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :intercept, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :inverse_of_intercept, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :correlation, event_name: 'cleaned_pvt_all'},
          { target: :datum, field: :correlation_squared, event_name: 'cleaned_pvt_all'}
      ]
    end


    def column_map
      [
          { target: :none },
          { target: :none },
          { target: :event, field: :labtime, event_name: EVENT_NAME },
          { target: :none },
          { target: :event, field: :labtime_decimal, event_name: SCHEDULED_EVENT_NAME },
          { target: :datum, field: :wake_period, event_name: EVENT_NAME},
          { target: :datum, field: :section_of_protocol, event_name: EVENT_NAME},
          { target: :datum, field: :test_type_identifier, event_name: EVENT_NAME},
          { target: :datum, field: :session_number, event_name: EVENT_NAME},
          { target: :datum, field: :handedness, event_name: EVENT_NAME},
          { target: :datum, field: :interstimulus_interval_min, event_name: EVENT_NAME},
          { target: :datum, field: :interstimulus_interval_max, event_name: EVENT_NAME},
          { target: :none },
          { target: :datum, field: :n_wrong, event_name: EVENT_NAME},
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :datum, field: :n_timeouts, event_name: EVENT_NAME},
          { target: :datum, field: :all_mean, event_name: EVENT_NAME},
          { target: :datum, field: :all_median, event_name: EVENT_NAME},
          { target: :datum, field: :all_std, event_name: EVENT_NAME},
          { target: :datum, field: :slow_mean, event_name: EVENT_NAME},
          { target: :datum, field: :slow_std, event_name: EVENT_NAME},
          { target: :datum, field: :fast_mean, event_name: EVENT_NAME},
          { target: :datum, field: :fast_std, event_name: EVENT_NAME},
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :datum, field: :n_correct, event_name: EVENT_NAME},
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :datum, field: :lapse_definition, event_name: EVENT_NAME},
          { target: :datum, field: :n_lapses, event_name: EVENT_NAME},
          { target: :datum, field: :lapse_transformation, event_name: EVENT_NAME},
          { target: :datum, field: :n_lapses_in_slow, event_name: EVENT_NAME},
          { target: :none },
          { target: :datum, field: :bin_length, event_name: EVENT_NAME},
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :datum, field: :slope, event_name: EVENT_NAME},
          { target: :datum, field: :intercept, event_name: EVENT_NAME},
          { target: :none },
          { target: :datum, field: :correlation, event_name: EVENT_NAME},
          { target: :none },
          { target: :datum, field: :test_duration_scheduled, event_name: EVENT_NAME},
          { target: :datum, field: :test_duration_actual, event_name: EVENT_NAME},
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :datum, field: :version, event_name: EVENT_NAME},
          { target: :event, field: :notes, event_name: EVENT_NAME}
      ]
    end

    def old_object_map(patient_year)
      [
          {
              class: Subject,
              existing_records: {action: :ignore, find_by: [:subject_code]}
          },
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: EVENT_NAME,
              static_fields: { labtime_year: patient_year },
              static_data_fields: { pvt_type: "visual pvt" }
          },
          {
              class: Event,
              existing_records: { action: :destroy, find_by: [:name, :subject_id]},
              event_name: SCHEDULED_EVENT_NAME,
              static_fields: { labtime_year: patient_year },
              static_data_fields: { pvt_type: "visual pvt" }
          }
      ]
    end

    def analyzed_object_map(patient_year)
      [
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: 'pvt_all_analyzed',
              static_fields: { labtime_year: patient_year },
          }
      ]
    end

    def object_map(patient_year)
      [
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: EVENT_NAME,
              static_fields: { labtime_year: patient_year },
              static_data_fields: { pvt_type: "visual pvt" }
          }
      ]
    end

  end
end

def find_admit_year(subject, source)
  if subject.admit_year.present?
    subject.admit_year
  else
    xls = Roo::Spreadsheet.open(source.location)
    m = /\d+\/\d+\/(\d+) \d+\:\d+/.match xls.sheet("FEV").row(2)[1]
    m[1].to_i
  end
end
