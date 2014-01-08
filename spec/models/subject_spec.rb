require 'spec_helper'

describe Subject do
  let(:subject_template) {build(:subject)}
  let(:subject_template2) {build(:subject)}
  describe "association setter (using project leader as example)" do

    it "should set new project leader" do
      researcher_template = build(:researcher)

      s = Subject.new(subject_code: subject_template.subject_code, pl_list: {list: [{delete: "0", first_name: researcher_template.first_name, last_name: researcher_template.last_name, email: researcher_template.email}]})
      s.subjects_project_leaders.length.should == 1
      s.subjects_project_leaders.first.researcher.email.should == researcher_template.email

      s.save
      s.should_not be_new_record
      s.project_leaders.count.should == 1
    end

    it "should set existing project leader" do
      researcher = create(:researcher)
      researcher_template = build(:researcher)

      s = Subject.new(subject_code: subject_template.subject_code, pl_list: {list: [{delete: "0", researcher_id: researcher.id}]})
      s.subjects_project_leaders.length.should == 1
      s.subjects_project_leaders.first.researcher.should == researcher
      s.save
      s.should_not be_new_record
      s.project_leaders.count.should == 1

      s2 = Subject.new(subject_code: subject_template2.subject_code, pl_list: {list: [{delete: "0", researcher_id: researcher.id, first_name: researcher_template.first_name, last_name: researcher_template.last_name, email: researcher_template.email}]})
      s2.subjects_project_leaders.length.should == 1
      s2.subjects_project_leaders.first.researcher.id.should == researcher.id
      s2.subjects_project_leaders.first.researcher.email.should == researcher_template.email
      s2.should be_new_record
      s2.save
      s2.should_not be_new_record
      s2.project_leaders.count.should == 1
    end

    it "should update project leader" do
      researcher = create(:researcher)
      researcher_template = build(:researcher)
      s = create(:subject, pl_count: 0)
      spl = SubjectsProjectLeader.create(researcher_id: researcher.id, subject_id: s.id)

      s.project_leaders.count.should == 1
      s.project_leaders.should include(researcher)

      s.update_attributes(pl_list: {list: [{delete: "0", subjects_project_leader_id: spl.id, first_name: researcher_template.first_name, last_name: researcher_template.last_name, email: researcher_template.email}]})
      s.reload
      s.project_leaders.first.id.should == researcher.id
      s.project_leaders.first.email.should == researcher_template.email
    end

    it "should delete project leader" do
      researcher_template = build(:researcher)

      s = create(:subject, pl_count: 1)
      s.update_attributes(pl_list: {list: [{delete: "1", subjects_project_leader_id: s.subjects_project_leaders.first.id }, {delete: "1", first_name: researcher_template.first_name, last_name: researcher_template.last_name, email: researcher_template.email}]})

      s.reload
      s.project_leaders.count.should == 0
    end

    it "should clear all existing project leaders and add new ones" do
      researcher_template = build(:researcher)

      s = create(:subject, pl_count: 1)
      s.update_attributes(pl_list: { clear_all: "1", list: [{first_name: researcher_template.first_name, last_name: researcher_template.last_name, email: researcher_template.email}]})

      s.reload
      s.project_leaders.count.should == 1
      s.project_leaders.first.email.should == researcher_template.email
    end

    it "should create new associations with clear_all flag even if association id given" do
      researcher = create(:researcher)
      researcher_template = build(:researcher)
      s = create(:subject, pl_count: 0)
      spl = SubjectsProjectLeader.create(researcher_id: researcher.id, subject_id: s.id)
      old_spl_id = spl.id

      s.project_leaders.count.should == 1
      s.project_leaders.should include(researcher)

      s.update_attributes(pl_list: {clear_all: "1", list: [{delete: "0", subjects_project_leader_id: spl.id, first_name: researcher_template.first_name, last_name: researcher_template.last_name, email: researcher_template.email}]})
      s.reload

      s.subjects_project_leaders.count.should == 1
      s.subjects_project_leaders.first.id.should_not == old_spl_id
    end
  end

  describe "#project_leader" do
    it "should return a single researcher of a given role" do
      s = create :subject
      r1 = create :researcher
      r2 = create :researcher

      SubjectsProjectLeader.create(subject_id: s.id, researcher_id: r1.id, role: "original")
      SubjectsProjectLeader.create(subject_id: s.id, researcher_id: r2.id, role: "current")

      s.reload

      s.project_leader("original").should == r1
      s.project_leader("current").should == r2
    end  
  end

  describe "#create_list" do
    it "should create a list of subjects and return valid subject object for created subjects and for existing subjects." do
      existing = create_list :subject, 3
      for_creation = build_list :subject, 4

      r = Subject.create_list((for_creation + existing).map(&:subject_code))

      MY_LOG.info r
      expect(r[:existing]).to eq(existing)
      expect(r[:created].map(&:subject_code)).to eq(for_creation.map(&:subject_code))

    end
  end

end
