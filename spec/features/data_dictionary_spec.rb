require "spec_helper"

feature "Data Dictionary entry creation" do
  scenario "User creates a new data dictionary", js: true do
    login_user

    create :string_type
    int_type = create :integer_type
    create :numeric_type
    create :datetime_type

    template_dd = build(:integer_dd, data_type: int_type, description: "Some description that may be fun.")

    visit data_dictionary_index_path
    click_on "Create Data Dictionary entry"

    fill_in "Title", :with => template_dd.title
    fill_in "data_dictionary[description]", :with => template_dd.description
    select_from_chosen int_type.name, :from => "Data type"

    da = find("#data_attributes")

    expect(page).to have_content("Data Attributes")

    da.fill_in "Unit", :with => "mm"
    da.fill_in "Min Value", :with => 0
    da.fill_in "Max Value", :with => 10

    1.times do
      da.click_link "Add Another Allowed Value"
    end

    expect(da.find("li:nth-of-type(2)")).to be_visible
    expect(da.find("ol")).to have_selector("li", :count => 2)

    count = 0
    da.find("ol").all("li").each_with_index do |li, i|
      li.fill_in "data_dictionary[allowed_values][]", :with => 1000 + i
      count += 1
    end

    expect(count).to eq 2

    page.find(".form-actions").click_button "Create Data Dictionary entry"

    show_page "dd3"
    expect(page).to have_content("Data Dictionary: #{template_dd.title}")
    expect(page).to have_content(template_dd.description)
    expect(page).to have_content(int_type.name)

    expect(page).to have_content("mm")

    expect(page).to have_content("0")
    expect(page).to have_content("10")

    expect(page).to have_content("1001")

  end
end
