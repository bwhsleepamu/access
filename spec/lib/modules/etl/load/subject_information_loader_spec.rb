require 'spec_helper'
require 'csv'
#require 'fakefs/spec_helpers'



describe ETL::SubjectInformationLoader do
  let(:source) {create(:source)}
  let(:documentation) {create(:documentation)}
  let(:user) {create(:user)}

  describe "main use case - light subjects" do
    let(:input_file_path) {"/usr/local/htdocs/access/spec/data/subject_information_loader/subject_info_test.xls"}

    before do
      create(:polychromatic_light_intervention)
      create(:monochromatic_light_intervention)
    end

    it "should load all new light subjects in test file" do
      si_loader = ETL::SubjectInformationLoader.new(input_file_path, :light, source, documentation)
      si_loader.load

      Subject.count.should == 8
      Subject.all.each do |s|
        MY_LOG.info s.inspect
        MY_LOG.info "HERE: #{s.subjects_project_leaders.first.inspect}"

        s.latest_source.should == source
        s.latest_documentation.should == documentation
        s.study.should_not be_nil
        s.study.study_nicknames.should_not be_empty
        s.subjects_project_leaders.length.should >= 1
        s.subjects_pis.length.should >= 1
        s.principal_investigators.length.should >= 1
        s.project_leaders.should_not be_empty
        s.irbs.should_not be_empty
        s.t_drive_location.should_not be_nil
        s.events.length.should == 1

        MY_LOG.info s.events
      end
    end


    it "should not duplicate information" do
      # Subjects, Studies, Publications, IRBs, Researchers, Events should be constant
      si_loader = ETL::SubjectInformationLoader.new(input_file_path, :light, source, documentation)
      si_loader.load

      Subject.count.should == 8
      Study.count.should == 6

      before_counts = { subjects: Subject.count, studies: Study.count, publications: Publication.count, irbs: Irb.count, researchers: Researcher.count, events: Event.count }

      si_loader = ETL::SubjectInformationLoader.new(input_file_path, :light, source, documentation)
      si_loader.load

      after_counts = { subjects: Subject.count, studies: Study.count, publications: Publication.count, irbs: Irb.count, researchers: Researcher.count, events: Event.count }

      expect(after_counts).to eq before_counts
    end
  end

  describe "main use case - fd subjects" do
    let(:input_file_path) {"/usr/local/htdocs/access/spec/data/subject_information_loader/fd_subjects_test.xlsx"}

    before do
      create(:forced_desynchrony_subject_information)
    end

    it "should load all new subjects in test file" do
      si_loader = ETL::SubjectInformationLoader.new(input_file_path, :forced_desynchrony, source, documentation)
      si_loader.load.should be_true

      Subject.count.should == 9
      Event.count.should == 4
      Study.count.should == 5
      Irb.count.should == 6

      Subject.all.each do |s|
        MY_LOG.info s.inspect
        MY_LOG.info "HERE: #{s.subjects_project_leaders.first.inspect}"

        s.latest_source.should == source
        s.latest_documentation.should == documentation
        s.subjects_project_leaders.length.should >= 1
        s.subjects_pis.length.should >= 1
        s.principal_investigators.length.should >= 1
        s.project_leaders.should_not be_empty

        MY_LOG.info s.events
      end
    end


    it "should not duplicate information" do
      # Subjects, Studies, Publications, IRBs, Researchers, Events should be constant
      si_loader = ETL::SubjectInformationLoader.new(input_file_path, :forced_desynchrony, source, documentation)
      si_loader.load.should be_true

      Subject.count.should == 9
      Study.count.should == 5

      before_counts = {subjects: Subject.count, studies: Study.count, publications: Publication.count, irbs: Irb.count, researchers: Researcher.count, events: Event.count}

      si_loader = ETL::SubjectInformationLoader.new(input_file_path, :forced_desynchrony, source, documentation)
      si_loader.load.should be_true

      after_counts = {subjects: Subject.count, studies: Study.count, publications: Publication.count, irbs: Irb.count, researchers: Researcher.count, events: Event.count}

      after_counts.should == before_counts
    end
  end
end



