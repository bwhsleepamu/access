require 'spec_helper'

describe Researcher do


  describe "researcher type" do
    before do
      pending "This functionality might be silly and un-needed"
    end
    it "should add a reseacher as a PL or PI with an associated subject" do
      s = create(:subject)
      pi_attrs = {first_name: "Bob", last_name: "Doe", email: "bobby@doe.com"}
      pl_attrs = pi_attrs
      pi_attrs[:subjects] = "pi"
      pl_attrs[:subjects] = "pl"

      pi = Researcher.create(pi_attrs)
      pl = Researcher.create(pl_attrs)

      pi.pi_subjects.length.should == 1
      pi.pl_subjects.length.should == 0
      pi.pi_subjects.first.should == s

      pl.pi_subjects.length.should == 0
      pl.pl_subjects.length.should == 1
      pl.pl_subjects.first.should == s
    end


  end

  describe "full name" do

    it "should add a researcher with a full name" do
      r = Researcher.new(full_name: "Bob St. Patrick", email: "bobbyst@gmail.com")
      r.valid?
      MY_LOG.info r.errors.full_messages
      r.save.should == true


      r.first_name.should == "Bob"
      r.last_name.should == "St. Patrick"      
    end
  end

  describe "#update_subject_association" do
    let(:subject) { create(:subject) }
    let(:attrs) { {first_name: "Bob", last_name: "Doe", email: "bobby@doe.com"} }
      
    it "should add an association if one does not exist" do
      r = Researcher.create(attrs)

      r.update_subject_association({type: :pi, subject_id: subject.id})

      r.pi_subjects.length.should == 1
      r.pi_subjects.first.should == subject
      r.pl_subjects.length.should == 0

      r.update_subject_association({type: :pl, subject_id: subject.id, role: "current"})
      r.reload
      r.pi_subjects.length.should == 1
      r.pl_subjects.length.should == 1
      r.pl_subjects.first.should == subject
    end

    it "should not add more associations if corresponding one exists" do
      r = Researcher.create(attrs)

      r.update_subject_association({type: :pi, subject_id: subject.id})
      r.update_subject_association({type: :pi, subject_id: subject.id})
      
      r.pi_subjects.length.should == 1       
    end

  end


end
