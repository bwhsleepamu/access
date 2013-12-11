require "spec_helper"

describe "Event dictionary" do
  before(:each) do
    login_user
  end

  it "user should be able to create a new event dictionary", :js => true do
    data_dictionaries = [create(:integer_dd), create(:string_dd), create(:data_dictionary), create(:text_dd), create(:date_dd)]
    event_tags = create_list(:event_tag, 3)

    visit event_dictionary_index_path
    click_on "Create Event Dictionary"

    show_page page, "0"

    template_ed = build(:event_dictionary)

    fill_in "Name", :with => template_ed.name
    fill_in "Description", :with => template_ed.description

    select_from_chosen event_tags[0].name, :from => "Event Tags"
    select_from_chosen event_tags[1].name, :from => "Event Tags"

    select_from_chosen data_dictionaries[0].title, :from => "Data Records"
    select_from_chosen data_dictionaries[1].title, :from => "Data Records"
    select_from_chosen data_dictionaries[2].title, :from => "Data Records"

    show_page page, "1"

    click_button "Create Event Dictionary"
    show_page page, "2"


    page.should have_content "Event Dictionary: #{template_ed.name}"
    page.should have_content template_ed.description

    page.should have_content event_tags[0].name
    page.should have_content event_tags[1].name
    page.should_not have_content event_tags[2].name

    page.should have_content data_dictionaries[0].title
    page.should have_content data_dictionaries[1].title
    page.should have_content data_dictionaries[2].title
    page.should_not have_content data_dictionaries[3].title

  end
end