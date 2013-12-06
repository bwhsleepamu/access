
FactoryGirl.define do

  factory :subject_group do
    sequence(:name) {|n| "subject_group_#{n}"}

    factory :subject_group_with_subjects do
      ignore do
        subject_count 3
        subject_code_list []
      end

      before(:create) do |subject_group, evaluator|
        if evaluator.subject_code_list.empty?
          subjects = create_list(:subject, evaluator.subject_count)
        else
          subjects = []
          evaluator.subject_code_list.each do |sc|
            subjects << create(:subject, subject_code: sc)
          end
        end

        subject_group.subjects = subjects
      end
    end
  end
end