require 'spec_helper'

describe ETL::DbfFileMerger do
  before do
    create(:subject, subject_code: "3227GX", admit_date: Time.zone.local(2012, 3, 4))
    create(:subject, subject_code: "3228GX", admit_date: Time.zone.local(2012, 3, 4))
    create(:subject, subject_code: "3232GX", admit_date: Time.zone.local(2012, 3, 4))
    create(:subject, subject_code: "3233GX", admit_date: Time.zone.local(2012, 3, 4))
    create(:subject, subject_code: "3237GX", admit_date: Time.zone.local(2012, 3, 4))
  end

  it "should work" do
    subject_list = ETL::TDriveCrawler.get_file_list :dbf, :new_forms, nil, "/home/pwm4/Windows/tdrive/IPM/CSR_32d_FD_20h"
    dbf_merger = ETL::DbfFileMerger.new subject_list, "spec/data/merged_dbf", "NewForms_", ["LABTIME", "SECONDS", "EVENTDESC", "EVENTCODE", "SUBJECT"]
    file_list = dbf_merger.merge

    file_list.length.should == 5
    file_list.each {|f| f.keys.length.should == 4 }

    MY_LOG.info file_list.to_yaml
    Dir.glob("spec/data/merged_dbf/*NewForms*").length.should == Subject.count

  end

end