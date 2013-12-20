require 'spec_helper'

describe ETL::ShFileMerger do
  it "should work" do
    s_d = '/home/pwm4/Desktop/NSBRI_55d_Entrainment'
    o_d = '/home/pwm4/Desktop/output'

    subjects = []
    subjects << create(:subject, subject_code: '18J5W')
    subjects << create(:subject, subject_code: '19A4W')
    subjects << create(:subject, subject_code: '2000W')

    sg = create(:subject_group)
    sg.subjects = subjects
    expect(sg.save).to be_true

    shm = ETL::ShFileMerger.new(s_d, o_d, sg)
    shm.merge

  end

end
