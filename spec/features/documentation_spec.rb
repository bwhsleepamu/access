require "spec_helper"

feature "Documentation creation" do
  scenario "User creates a new, full documentation" do
    login_user

    doc_template = build(:documentation)
    previous_docs = create_list :documentation, count: 5
    outside_links = ["I:/some/path/to/folder/or/file", "www.google.com"]

    visit new_documentation_path

    page.save_screenshot("spec/screenshots/1.png")

    fill_in("Title", with: doc_template.title)
    fill_in("Author", with: doc_template.author)
    fill_in("Description", with: doc_template.description_of_procedure)

    outside_links.each do |link|
      click "add linked"

      find("//div[@id='links']//div[@class='control-group' and last()]").fill_in('input', with: link)
    end


    page.save_screenshot("spec/screenshots/2.png")




  end
end