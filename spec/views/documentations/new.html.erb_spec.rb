require 'spec_helper'

describe "documentations/new" do
  before(:each) do
    assign(:documentation, stub_model(Documentation,
      :title => "MyString",
      :author => "MyString",
      :description => "MyString"
    ).as_new_record)
  end

  it "renders new documentation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", documentations_path, "post" do
      assert_select "input#documentation_title[name=?]", "documentation[title]"
      assert_select "input#documentation_author[name=?]", "documentation[author]"
      assert_select "input#documentation_description[name=?]", "documentation[description]"
    end
  end
end
