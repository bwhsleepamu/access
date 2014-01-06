require 'spec_helper'

describe ETL::ShFileMerger do
  it "should work for subjects with no T Drive location" do
    subjects = []
    subjects << create(:subject, subject_code: '18J5W')
    subjects << create(:subject, subject_code: '19A4W')
    subjects << create(:subject, subject_code: '2000W')

    sg = create(:subject_group)
    sg.subjects = subjects

    merge_test(sg)
  end

  it "should work for subjects with a T Drive location" do
    subjects = []
    subjects << create(:subject, subject_code: '1983W', t_drive_location: '/usr/local/htdocs/access/spec/data/sh_file_merger/t_drive_dir/some_dir/1983W')
    subjects << create(:subject, subject_code: '19A4W', t_drive_location: '/usr/local/htdocs/access/spec/data/sh_file_merger/t_drive_dir/some_dir')

    sg = create(:subject_group)
    sg.subjects = subjects

    merge_test(sg)
  end


  def merge_test(sg)
    s_d = '/usr/local/htdocs/access/spec/data/sh_file_merger/study_dir'
    o_d = '/usr/local/htdocs/access/spec/data/sh_file_merger/output'

    Find.find(o_d) do |path|
      File.delete(path) unless File.directory? path
    end

    expect(sg.save).to be_true

    shm = ETL::ShFileMerger.new({source_dir: s_d, output_dir: o_d, subject_group: sg})
    shm.merge

    expect(File.exists?(File.join(o_d, shm.sp_output_name))).to be_true
    expect(File.exists?(File.join(o_d, shm.lt_output_name))).to be_true
    expect(File.size(File.join(o_d, shm.sp_output_name))).to be > 200
    expect(File.size(File.join(o_d, shm.lt_output_name))).to be > 200
  end

end
