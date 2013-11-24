require "spec_helper"

feature "Source type creation" do
  scenario "User creates a new, full source type", js: true do
    login_user

    source_type_template = build(:source_type)

    visit new_source_type_path

    fill_in("Name", with: source_type_template.name)
    fill_in("source_type[description]", with: source_type_template.description)

    expect {
      click_on "Create Source type"
    }.to change(SourceType, :count).by(1)
  end
end

