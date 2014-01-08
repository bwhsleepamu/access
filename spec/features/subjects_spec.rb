require "spec_helper"

feature "Subject List" do
  scenario "User initializes a list of new subjects", js: true do
    login_user

    not_shown = create_list :subject, 2
    existing = create_list :subject, 3
    for_creation = build_list :subject, 4

    visit new_list_subjects_path

    fill_in "subjects[subject_codes]", with: (existing + for_creation).map(&:subject_code).split(", ")

    click_on "Create Subjects"


    expect(Subject.count).to eq(existing.length + for_creation.length + not_shown.length)
    existing.each {|s| expect(page).to have_content s.subject_code }
    for_creation.each {|s| expect(page).to have_content s.subject_code }
    not_shown.each {|s| expect(page).to have_no_content s.subject_code }

  end
end
