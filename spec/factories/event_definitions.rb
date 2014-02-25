FactoryGirl.define do

######################################################################################################################
##
##
# CUSTOM EVENT RECORDS
## REFACTOR? PLEASE?
##
######################################################################################################################

  factory :polychromatic_light_intervention, class: EventDictionary do
    name "polychromatic_light_intervention"
    description "a subject's params for light intervention"

    after(:create) { |event_dictionary|
      dt = DataType.find_by_name("numeric_type")
      dt = create(:numeric_type) if dt.blank?

      create(:data_dictionary, title: "polychromatic_light_source", data_type: dt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "polychromatic_light_level_target", data_type: dt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "polychromatic_light_level_measured", data_type: dt, event_dictionary: [event_dictionary])
    }

  end

  factory :monochromatic_light_intervention, class: EventDictionary do
    name "monochromatic_light_intervention"
    description "a subject's params for light intervention"

    after(:create) { |event_dictionary|
      dt = DataType.find_by_name("numeric_type")
      dt = create(:numeric_type) if dt.blank?

      create(:data_dictionary, title: "monochromatic_light_wavelength", data_type: dt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "monochromatic_light_irradiance_target", data_type: dt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "monochromatic_light_irradiance_measured", data_type: dt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "monochromatic_light_photon_flux_target", data_type: dt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "monochromatic_light_photon_flux_measured", data_type: dt, event_dictionary: [event_dictionary])
    }
  end

  factory :actigraphy_measurement, class: EventDictionary do
    name "actigraphy_measurement"
    description "epoch of Actigraphy L data"

    after(:create) { |event_dictionary|
      nt = DataType.find_by_name("numeric_type")
      it = DataType.find_by_name("integer_type")
      nt = create(:numeric_type) if nt.blank?
      it = create(:integer_type) if it.blank?

      create(:data_dictionary, title: "activity_count", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "epoch_length", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "light_level", data_type: nt, event_dictionary: [event_dictionary])
    }
  end

  factory :forced_desynchrony_subject_information, class: EventDictionary do
    name "forced_desynchrony_subject_information"
    description "FD Subject Info"
    after(:create) do |event_dictionary|
      nt = DataType.find_by_name("numeric_type")
      tt = DataType.find_by_name("text_type")

      nt = create(:numeric_type) if nt.blank?
      tt = create(:text_type) if tt.blank?

      create(:data_dictionary, title: "age_group", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "t_cycle", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "sleep_period_duration", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "wake_period_duration", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "analysis_start_time", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "analysis_end_time", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "intervention", data_type: tt, event_dictionary: [event_dictionary])
    end

  end

  factory :subject_demographics, class: EventDictionary do
    name "subject_demographics"
    after(:create) do |event_dictionary|
      it = DataType.find_by_name("integer_type")
      nt = DataType.find_by_name("numeric_type")
      st = DataType.find_by_name("string_type")
      dt = DataType.find_by_name("date_type")

      it = create(:integer_type) if it.blank?
      nt = create(:numeric_type) if nt.blank?
      st = create(:string_type) if st.blank?
      dt = create(:date_type) if dt.blank?

      create(:data_dictionary, title: "suite_number", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "log_book_number", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "day_of_birth", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "month_of_birth", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "year_of_birth", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "age", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "sex", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "ethnic_category", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "race", data_type: st, multivalue: true, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "height", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "weight", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "owl_lark_score", data_type: nt, event_dictionary: [event_dictionary])

    end
  end
  factory :subject_vitals, class: EventDictionary do
    name "subject_vitals"
    after(:create) do |event_dictionary|
      nt = DataType.find_by_name("numeric_type")
      nt = create(:numeric_type) if nt.blank?

      create(:data_dictionary, title: "blood_pressure_systolic", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "blood_pressure_diastolic", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "heart_rate", data_type: nt, event_dictionary: [event_dictionary])
    end
  end
  factory :subject_sleep_habits, class: EventDictionary do
    name "subject_sleep_habits"
    after(:create) do |event_dictionary|
      tt = DataType.find_by_name("time_type")
      tt = create(:time_type) if tt.blank?

      create(:data_dictionary, title: "habitual_day_off_weekend_bed_time_lower_bound", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "habitual_day_off_weekend_bed_time_upper_bound", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "habitual_school_work_bed_time_lower_bound", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "habitual_school_work_bed_time_upper_bound", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "habitual_day_off_weekend_wake_time_lower_bound", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "habitual_day_off_weekend_wake_time_upper_bound", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "habitual_school_work_wake_time_lower_bound", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "habitual_school_work_wake_time_upper_bound", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "desired_bedtime", data_type: tt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "desired_waketime", data_type: tt, event_dictionary: [event_dictionary])
    end
  end

  factory :phase_analysis_cbt, class: EventDictionary do
    name "phase_analysis_cbt"
    after(:create) do |event_dictionary|

      dds = ["tau", "circadian_amplitude", "t_cycle_amplitude", "composite_maximum", "fundamental_maximum"].map { |dt| DataDictionary.find_by_title(dt) }
      event_dictionary.data_dictionary = dds
      event_dictionary.save
    end
  end

  factory :nosa_analysis_melatonin, class: EventDictionary do
    name "nosa_analysis_melatonin"
    after(:create) do |event_dictionary|
      dds = ["tau", "circadian_amplitude", "t_cycle_amplitude", "composite_maximum", "fundamental_maximum", "unit_of_measure"].map { |dt| DataDictionary.find_by_title(dt) }
      event_dictionary.data_dictionary = dds
      event_dictionary.save
    end
  end

=begin

  005: In Bed ==> in_bed_scheduled
  005: Out of Bed ==> out_of_bed_scheduled
  022: Sleep Episode (start) ==> sleep_start_scheduled, lighting_change_scheduled (sleep_start has episode_number)
  023: Wake Time (start) ==> wake_start_scheduled, lighting_change_scheduled (wake_start has episode_number)
  024: Lighting Change (start) ==> lighting_change_scheduled
  OTHERS:
      new_forms_event
  - event_code
  - event_description
=end

  factory :dbf_loader_dictionaries, class: EventDictionary do
    name "sleep_start_scheduled"
    after(:create) do |event_dictionary|
      nt = create(:numeric_type)
      st = create(:string_type)

      ll = create(:data_dictionary, title: "light_level", data_type: nt)
      en = create(:data_dictionary, title: "episode_number", data_type: nt)
      ec = create(:data_dictionary, title: "event_code", data_type: nt)
      ed = create(:data_dictionary, title: "event_description", data_type: st)

      event_dictionary.data_dictionary = [en]
      create(:event_dictionary, name: "new_forms_event", data_dictionary: [ec, ed])
      create(:event_dictionary, name: "in_bed_start_scheduled")
      create(:event_dictionary, name: "in_bed_end_scheduled")
      create(:event_dictionary, name: "out_of_bed_start_scheduled")
      create(:event_dictionary, name: "out_of_bed_end_scheduled")
      create(:event_dictionary, name: "wake_start_scheduled", data_dictionary: [en])
      create(:event_dictionary, name: "wake_end_scheduled")
      create(:event_dictionary, name: "sleep_end_scheduled")

      create(:event_dictionary, name: "lighting_block_start_scheduled", data_dictionary: [ll])
      create(:event_dictionary, name: "lighting_block_end_scheduled")

    end
  end

  factory :interval_list_dictionaries, class: EventDictionary do
    name "lighting_block_start_scheduled"

    after(:create) do |event_dictionary|
      nt = create(:numeric_type)
      ll = create(:data_dictionary, title: "light_level", data_type: nt)
      event_dictionary.data_dictionary = [ll]
      create(:event_dictionary, name: "lighting_block_end_scheduled")
    end
  end

  factory :scored_pvt, class: EventDictionary do
    name "cleaned_pvt_all"
    after(:create) do |event_dictionary|
      it = DataType.find_by_name("integer_type")
      nt = DataType.find_by_name("numeric_type")
      st = DataType.find_by_name("string_type")
      dt = DataType.find_by_name("date_type")

      it = create(:integer_type) if it.blank?
      nt = create(:numeric_type) if nt.blank?
      st = create(:string_type) if st.blank?
      dt = create(:date_type) if dt.blank?

      create(:data_dictionary, title: "all_mean", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "all_median", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "all_std", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "bin_length", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "correlation", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "fast_mean", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "fast_std", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "good", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "handedness", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "include", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "intercept", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "interstimulus_interval_max", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "interstimulus_interval_min", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "lapse_definition", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "lapse_transformation", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "n_anticipation_correct", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "n_anticipation_wrong", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "n_coincidence", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "n_correct", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "n_lapses", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "n_lapses_in_slow", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "n_timeouts", data_type: it, multivalue: true, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "n_wrong", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "pvt_type", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "section_of_protocol", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "session_number", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "slope", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "slow_mean", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "slow_std", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "test_duration_actual", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "test_duration_scheduled", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "test_type_identifier", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "valid_data", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "version", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "wake_period", data_type: it, event_dictionary: [event_dictionary])
    end
  end

  factory :scheduled_pvt, class: EventDictionary do
    name "scheduled_pvt_all"

    after(:create) do |event_dictionary|
      st = DataType.find_by_name("string_type")
      st = create(:string_type) if st.blank?

      dd = DataDictionary.find_by_title "pvt_type"
      if dd
        event_dictionary.data_dictionary << dd
      else
        create(:data_dictionary, title: "pvt_type", data_type: st, event_dictionary: [event_dictionary])
      end
      event_dictionary.save

    end
  end


  factory :vas_scalesad_cleaned, class: EventDictionary do
    name "vas_scalesad_cleaned"

    after(:create) do |event_dictionary|
      it = DataType.find_by_name("integer_type")
      nt = DataType.find_by_name("numeric_type")
      st = DataType.find_by_name("string_type")

      it = create(:integer_type) if it.blank?
      nt = create(:numeric_type) if nt.blank?
      st = create(:string_type) if st.blank?

      create(:data_dictionary, title: "wake_period", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "section_of_protocol", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "test_type_identifier", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "session_number", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "sleepy_alert", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "excited_calm", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "weak_strong", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "groggy_clearheaded", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "clumsy_wellcoordinated", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "sluggish_energetic", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "discontented_contented", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "troubled_tranquil", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "mentallyslow_quickwitted", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "tense_relaxed", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "dreamy_attentive", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "incompetent_competent", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "happy_sad", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "hostile_friendly", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "bored_interested", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "withdrawn_sociable", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "cold_warm", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "version", data_type: st, event_dictionary: [event_dictionary])
    end
  end

  factory :vas_shtscale_cleaned, class: EventDictionary do
    name "vas_shtscale_cleaned"

    after(:create) do |event_dictionary|
      it = DataType.find_by_name("integer_type")
      nt = DataType.find_by_name("numeric_type")
      st = DataType.find_by_name("string_type")

      it = create(:integer_type) if it.blank?
      nt = create(:numeric_type) if nt.blank?
      st = create(:string_type) if st.blank?

      create(:data_dictionary, title: "wake_period", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "section_of_protocol", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "test_type_identifier", data_type: st, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "session_number", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "sleepy_alert", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "happy_sad", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "excited_calm", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "version", data_type: st, event_dictionary: [event_dictionary])
    end

  end


  factory :melatonin_sample, class: EventDictionary do
    name "melatonin_sample"

    after(:create) do |event_dictionary|
      it = DataType.find_by_name("integer_type")
      nt = DataType.find_by_name("numeric_type")
      st = DataType.find_by_name("string_type")

      it = create(:integer_type) if it.blank?
      nt = create(:numeric_type) if nt.blank?
      st = create(:string_type) if st.blank?

      create(:data_dictionary, title: "sample_number", data_type: it, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "pg_ml_concentration", data_type: nt, event_dictionary: [event_dictionary])
      create(:data_dictionary, title: "pmol_l_concentration", data_type: nt, event_dictionary: [event_dictionary])
    end

  end


  factory :vas_scalesad_scheduled, class: EventDictionary do
    name "vas_scalesad_scheduled"
  end

  factory :vas_shtscale_scheduled, class: EventDictionary do
    name "vas_shtscale_scheduled"
  end
end


