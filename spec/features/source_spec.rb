require "spec_helper"

feature "Source creation" do
  scenario "User creates a new, full source", js: true do
    login_user

    source_type = create(:source_type)
    source_template = build(:full_source, source_type_id: source_type.id)
    previous_sources = create_list :source, 3
    p_source = create(:source)

    visit new_source_path

    select_from_chosen source_type.name, from: "Source type"
    fill_in("Location", with: source_template.location)
    fill_in("Original location", with: source_template.original_location)
    fill_in("source[description]", with: source_template.description)

    select_from_chosen p_source.location, from: "Parent source"

    previous_sources[0..2].each_with_index do |s, i|
      select_from_chosen s.location, from: "Child sources"
    end

    expect {
      click_on "Create Source"
    }.to change(Source, :count).by(1)
  end
end

