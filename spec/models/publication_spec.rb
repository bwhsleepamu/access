require 'spec_helper'

describe Publication do
  describe "find_by_combo" do
    it "should find the same publication" do
      p = create(:publication, title: "some title", year: "2000")
      Publication.find_by_combo({pubmed_id: p.pubmed_id, authors: p.authors, year: p.year, title: p.title}).should == p

      p = Publication.create({:pubmed_id=>"", :endnote_id=>"", :title=>"THE EFFECT OF A SINGLE CONTINUOUS TWO MINUTE BRIGHT LIGHT PULSE ON THE HUMAN CIRCADIAN PACEMAKER", :authors=>"St. Hilarie et al.", :journal=>"Sleep 2011 Abstract", :year=>"2011"})
      MY_LOG.info "ERRORS: #{p.errors.full_messages}"
      p.should_not be_new_record

      p1 = Publication.find_by_combo({:pubmed_id=>"", :endnote_id=>"", :title=>"THE EFFECT OF A SINGLE CONTINUOUS TWO MINUTE BRIGHT LIGHT PULSE ON THE HUMAN CIRCADIAN PACEMAKER", :authors=>"St. Hilarie et al.", :journal=>"Sleep 2011 Abstract", :year=>"2011"})
      p.should == p1
    end



  end
end
