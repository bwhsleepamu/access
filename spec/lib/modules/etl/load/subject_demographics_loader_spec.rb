require 'spec_helper'
require 'csv'
#require 'fakefs/spec_helpers'



describe ETL::SubjectDemographicsLoader do
  let(:source) {create(:source)}
  let(:documentation) {create(:documentation)}
  let(:user) {create(:user)}

  describe "main use case - light subjects" do
    let(:input_file_path) {"/usr/local/htdocs/access/spec/data/subject_demographics_test.xls"}

    before do
      create(:subject_demographics)
      create(:subject_vitals)
      create(:subject_sleep_habits)
    end

    it "should load all new subjects in test file" do
      sd_loader = ETL::SubjectDemographicsLoader.new(input_file_path, :light, source, documentation)
      sd_loader.load

      Subject.count.should == 8
      Subject.all.each do |s|
        s.events.length.should == 3
        MY_LOG.info "\n### #{s.subject_code}"
        s.events.each do |e|
          MY_LOG.info e.name
          e.data.each do |d|
            MY_LOG.info "   #{d.title} | #{d.value}"
          end
        end

        MY_LOG.info s.events
      end
    end


    it "should not duplicate information" do
      # Subjects, Studies, Publications, IRBs, Researchers, Events should be constant
      sd_loader = ETL::SubjectDemographicsLoader.new(input_file_path, :light, source, documentation)
      sd_loader.load

      Subject.count.should == 8

      before_counts = {subjects: Subject.count, events: Event.count}

      sd_loader = ETL::SubjectDemographicsLoader.new(input_file_path, :light, source, documentation)
      sd_loader.load
      after_counts = {subjects: Subject.count, events: Event.count}

      before_counts.should == after_counts
    end
  end

  describe "main use case - fd subjects" do
    let(:input_file_path) {"/usr/local/htdocs/access/spec/data/fd_subjects_test.xlsx"}

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