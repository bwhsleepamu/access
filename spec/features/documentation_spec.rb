require "spec_helper"

feature "Documentation creation" do
  scenario "User creates a new, full documentation", js: true do
    login_user

    doc_template = build(:documentation)
    previous_docs = create_list :documentation, 5
    outside_links = ["I:/some/path/to/folder/or/file", "www.google.com"]

    visit new_documentation_path

    fill_in("Title", with: doc_template.title)
    fill_in("Author", with: doc_template.author)
    fill_in("documentation[description]", with: doc_template.description)

    outside_links.each_with_index do |i, link|
      click_link "add new link"

      link_f = find("div.additional fieldset:last-of-type fieldset:last-of-type")
      link_f.fill_in("Title", with: "Title_#{i}")
      link_f.fill_in("Path", with: link)
    end


    previous_docs[0..2].each do |d|
      select_from_chosen(d.display_name, from: "documentation_supporting_documentation_ids")
    end

    expect {
      click_on "Create Documentation"
    }.to change(Documentation, :count).by(1)

  end
end