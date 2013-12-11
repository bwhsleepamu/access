require "spec_helper"

feature "Data type creation" do
  scenario "User creates a new, full data type", js: true do
    login_user

    dt_template = build(:integer_type)

    visit new_data_type_path

    fill_in("Name", with: dt_template.name)
    select dt_template.storage, from: 'Storage'

    check 'Enable length restrictions?' if dt_template.length
    check 'Enable range restrictions?' if dt_template.range
    check 'Enable restricting allowed values?' if dt_template.values
    check 'Enable multiple values?' if dt_template.multiple

    expect {
      click_on "Create Data type"
    }.to change(DataType, :count).by(1)
  end
end