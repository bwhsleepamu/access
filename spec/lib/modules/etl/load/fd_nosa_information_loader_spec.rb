require 'spec_helper'
require 'csv'
#require 'fakefs/spec_helpers'



describe ETL::FdNosaInformationLoader do
  let(:source) {create(:source)}
  let(:documentation) {create(:documentation)}
  let(:user) {create(:user)}
  let(:input_file_path) {"/usr/local/htdocs/access/spec/data/fd_info_test.xls"}

  before do
    nt = DataType.find_by_name("numeric_type")
    nt = create(:numeric_type) if nt.blank?

    create(:data_dictionary, title: "tau", data_type: nt)
    create(:data_dictionary, title: "circadian_amplitude", data_type: nt)
    create(:data_dictionary, title: "t_cycle_amplitude", data_type: nt)
    create(:data_dictionary, title: "composite_maximum", data_type: nt)
    create(:data_dictionary, title: "fundamental_maximum", data_type: nt)
    create(:data_dictionary, title: "unit_of_measure", data_type: create(:string_type))
    create(:phase_analysis_cbt)
    create(:nosa_analysis_melatonin)
  end

  it "should load all new subjects in test file and not duplicate information" do
    loader = ETL::FdNosaInformationLoader.new(input_file_path, source, documentation)
    loader.load

    Subject.count.should == 8
    before_counts = {subjects: Subject.count, events: Event.count}

    Subject.all.each do |s|
      s.events.length.should >= 1
      s.events.length.should <= 2

      MY_LOG.info "\n### #{s.subject_code}"
      s.events.each do |e|
        MY_LOG.info e.name
        e.data.each do |d|
          MY_LOG.info "   #{d.title} | #{d.value}"
        end
      end

      MY_LOG.info s.events

    end

    loader = ETL::FdNosaInformationLoader.new(input_file_path, source, documentation)
    loader.load
    after_counts = {subjects: Subject.count, events: Event.count}

    before_counts.should == after_counts

  end
end