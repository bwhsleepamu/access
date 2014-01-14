FactoryGirl.define do
  factory :constant_routine_start, class: EventDictionary do
    name "constant_routine_start"

    after(:create) do |event_dictionary|
      it = DataType.find_by_name("integer_type")
      it = create(:integer_type) if it.blank?

      create(:data_dictionary, title: "constant_routine_number", data_type: it, event_dictionary: [event_dictionary])
    end

  end




end