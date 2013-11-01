require 'spec_helper'

describe "documentations/index" do
  before(:each) do
    assign(:documentations, [
      stub_model(Documentation,
        :title => "Title",
        :author => "Author",
        :description => "Description"
      ),
      stub_model(Documentation,
        :title => "Title",
        :author => "Author",
        :description => "Description"
      )
    ])
  end

  it "renders a list of documentations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Author".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
