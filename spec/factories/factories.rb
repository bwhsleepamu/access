FactoryGirl.define do
  factory :user do
    first_name "Test"
    sequence(:last_name) {|n| "Dummy_#{n}" }
    password { "secret" }
    sequence(:email) {|n| "user_#{n}@example.com"}

    factory :active_user do
      system_admin false
      status "active"
    end

    factory :admin do
      system_admin true
      status "active"
    end
  end

  ##
  # Dictionaries
  factory :data_dictionary do
    sequence(:title) {|n| "data_record_#{n}"}
    data_type

    factory :text_dd do
      association :data_type, factory: :text_type
    end

    factory :string_dd do
      association :data_type, factory: :string_type

    end

    factory :time_dd do
      association :data_type, factory: :time_type

    end

    factory :date_dd do
      association :data_type, factory: :date_type

    end

    factory :datetime_dd do
      association :data_type, factory: :datetime_type

    end

    factory :integer_dd do
      association :data_type, factory: :integer_type

    end

    factory :numeric_dd do
      association :data_type, factory: :numeric_type

    end
  end

  factory :data_type do
    sequence(:name) {|n| "generic_type_#{n}"}
    storage "text_value"

    factory :text_type do
      name "text_type"
      storage "text_value"
      length false
      multiple false
      range false
      values false
    end

    factory :string_type do
      name "string_type"
      storage "text_value"
      length true
      multiple true
      range false
      values true
    end

    factory :time_type do
      name "time_type"
      storage "time_value"
      length false
      multiple false
      range true
      values false
    end

    factory :date_type do
      name "date_type"
      storage "time_value"
      length false
      multiple false
      range true
      values false
    end

    factory :datetime_type do
      name "datetime_type"
      storage "time_value"
      length false
      multiple false
      range true
      values false
    end

    factory :integer_type do
      name "integer_type"
      storage "num_value"
      length false
      multiple true
      range true
      values true
    end

    factory :numeric_type do
      name "numeric_type"
      storage "num_value"
      length false
      multiple false
      range true
      values false
    end
  end

  factory :event_dictionary do
    sequence(:name) {|n| "event_record_#{n}"}
    description "Some event dictionary description that I came up with."

    ignore do
      event_tag_count 2
    end

    after(:create) {|event_dictionary, evaluator| create_list(:event_tag, evaluator.event_tag_count, event_dictionary: [event_dictionary])}

    factory :event_dictionary_with_data_records do
      ignore do
        data_record_count 5
      end

      after(:create) {|event_dictionary, evaluator| create_list(:data_dictionary, evaluator.data_record_count, event_dictionary: [event_dictionary])}
    end
  end

  ##
  # Events and Data

  factory :event_from_dictionary, class: Event do
    # Needs name
    subject
    source
    documentation

    before(:create) do |event, evaluator|
      ed = EventDictionary.find_by_name(event.name)
      event.realtime = Time.zone.now unless event.realtime.present? or event.labtime.present?
      ed.data_dictionary.each do |dd|
        event.data << build(:datum_from_dictionary, title: dd.title)
      end
    end

  end

  factory :datum_from_dictionary, class: Datum do
    # Needs title
    before(:create) do |datum, evaluator|
      datum.data_dictionary = DataDictionary.find_by_title(datum.title)
      if dd.data_type.storage == "num_value"
        datum.value = Random.rand(100)
      elsif dd.data_type.storage == "text_value"
        datum.value = "test_text_#{Radom.rand(100)}"
      else
        datum.value = Time.zone.now
      end
    end
  end


  factory :event do
    subject
    sequence(:name) {|n| "event_record_#{n}"}
    source
    documentation

    factory :event_realtime do
      realtime { Time.zone.now() }
    end

    before(:create) do |event, evaluator|
      create(:event_dictionary, name: event.name)
      event.realtime = Time.zone.now if event.labtime.nil? and event.realtime.nil?
    end
  end

  factory :datum do
    data_dictionary
    event
    notes "notes about data"

    source
    documentation

    ignore do
      data_value_count 1
      quality_flag_count 1
    end

    after(:create) do |datum, evaluator|
      create_list(:data_value, evaluator.data_value_count, datum: datum)
      create_list(:quality_flag, evaluator.quality_flag_count, data: [datum])
    end
  end

  factory :data_value do
    #value "1234"
  end

  ## 
  # Others

  factory :event_tag do
    sequence(:name) {|n| "event_tag_#{n}"}

  end



  factory :source do
    source_type
    user
    location "pointer to some place or file"
    description "description of this source"

    factory :full_source do
      original_location "somewhere else where original file lives"
    end
  end

  factory :source_type do
    sequence(:name) {|n| "source_type_#{n}"}
    description "Some source type description up in here."
  end

  factory :documentation do
    user
    author "Doc Author"
    title "Doc Title"
    description "Some description of how things are done."
    #origin_location "Where more info can be gathered."
  end

  factory :quality_flag do
    sequence(:name) {|n| "quality_flag_#{n}"}
    description "Some stupid description."
  end

  factory :irb do
    sequence(:irb_number) {|n| "12P1234#{n}"}
    title "Irb Title"
  end

  factory :publication do
    pubmed_id "23423423452"
  end

  factory :researcher do
    first_name "Some"
    sequence(:last_name) {|n| "Researcher#{n}"}
    sequence(:email) {|n| "researcher#{n}@example.com"}
  end

  factory :study do
    sequence(:official_name) {|n| "Study #{n}"}

    ignore do
      study_nickname_count 0
      subject_count 0
    end

    after(:create) do |study, evaluator|
      create_list(:study_nickname, evaluator.study_nickname_count, study: study)
      create_list(:subject, evaluator.subject_count, study: study)
    end
  end

  factory :study_nickname do
    nickname "Some study nickname"
  end

  factory :subject do
    sequence(:subject_code) {|n| "12G#{n}V"}

    ignore do
      pl_count 1
      pi_count 1
      irb_count 1
      publication_count 0
    end
    after(:create) do |subject, evaluator|
      create_list(:researcher, evaluator.pl_count, pl_subjects: [subject])
      create_list(:researcher, evaluator.pi_count, pi_subjects: [subject])
      create_list(:irb, evaluator.irb_count, subjects: [subject])
      create_list(:publication, evaluator.publication_count, subjects: [subject])
    end
  end


end


