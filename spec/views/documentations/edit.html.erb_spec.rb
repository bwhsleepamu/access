require 'spec_helper'

describe "documentations/edit" do
  before(:each) do
    @documentation = assign(:documentation, stub_model(Documentation,
      :title => "MyString",
      :author => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit documentation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", documentation_path(@documentation), "post" do
      assert_select "input#documentation_title[name=?]", "documentation[title]"
      assert_select "input#documentation_author[name=?]", "documentation[author]"
      assert_select "input#documentation_description[name=?]", "documentation[description]"
    end
  end
end
