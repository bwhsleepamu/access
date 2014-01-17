require 'spec_helper'

describe ETL::TDriveCrawler do
  it "explores" do
    s1 = create(:subject, subject_code: '22B1DX')
    s2 = create(:subject, subject_code: '21A4DX')
    s3 = create(:subject, subject_code: '2823GX')
    s4 = create(:subject, subject_code: '1819XX')

    sg1 = SubjectGroup.new(name: "sg1")
    sg1.subjects = [s3, s4]
    expect(sg1.save).to be_true

    sg2 = SubjectGroup.new(name: 'sg2')
    sg2.subjects = [s1, s2]
    expect(sg2.save).to be_true

    descriptions = {sg1.name => "Some desc for these sources", sg2.name => "SOme other desc for sources"}
    subject_group_list = {sg1 => "/I/AMU Cleaned Data Sets", sg2 => "/X/Studies/Analyses/PRET-modafinil/data/cog"}
    output_dir = "/usr/local/htdocs/access/spec/data/pvt_all_finder"
    patterns = {sg1.name => /.*testing\/\d[0-9a-z]*[a-z][0-9a-z]*_.*pvt.*fev.*(\.xls)\z/i, sg2.name => /.*pvtall.*(\.xls)\z/i}


    f = ETL::PvtAllFinder.new(subject_group_list, output_dir, descriptions, patterns)
    f.explore
  end
end