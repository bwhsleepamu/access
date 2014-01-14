FactoryGirl.define do
  factory :light_episode_start, class: EventDictionary do
    name "light_episode_start"

    after(:create) do |event_dictionary|
      nt = DataType.find_by_name("numeric_type")
      nt = create(:numeric_type) if nt.blank?

      create(:data_dictionary, title: "light_level", data_type: nt, event_dictionary: [event_dictionary])
    end

  end




end