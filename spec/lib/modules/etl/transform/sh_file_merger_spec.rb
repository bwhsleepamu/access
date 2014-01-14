require 'spec_helper'

describe ETL::ShFileMerger do
  before do
    create(:source_type, name: 'LT<lux value>.S~H')
    create(:source_type, name: 'IBOB.S~H')
    create(:source_type, name: 'CR.S~H')
    create(:source_type, name: 'Comma Delimited File')
    @u = create(:user)
  end

  it "should work for subjects with no T Drive location" do
    subjects = []
    subjects << create(:subject, subject_code: '18J5W')
    subjects << create(:subject, subject_code: '19A4W')
    subjects << create(:subject, subject_code: '2000W')

    sg = create(:subject_group)
    sg.subjects = subjects

    merge_test(sg, true)
  end

  it "should work for subjects with a T Drive location" do
    subjects = []
    subjects << create(:subject, subject_code: '1983W', t_drive_location: '/usr/local/htdocs/access/spec/data/sh_file_merger/t_drive_dir/some_dir/1983W')
    subjects << create(:subject, subject_code: '1916W', t_drive_location: '/usr/local/htdocs/access/spec/data/sh_file_merger/t_drive_dir/some_dir')

    sg = create(:subject_group)
    sg.subjects = subjects

    merge_test(sg)
  end


  def merge_test(sg, no_loc = false)
    s_d = '/usr/local/htdocs/access/spec/data/sh_file_merger/study_dir'
    o_d = '/usr/local/htdocs/access/spec/data/sh_file_merger/output'

    Find.find(o_d) do |path|
      File.delete(path) unless File.directory? path
    end

    expect(sg.save).to be_true

    shm = ETL::ShFileMerger.new({source_dir: s_d, output_dir: o_d, subject_group: sg, find_missing_t_drive_location: no_loc, user_email: @u.email})
    expect(shm.merge).to be_true

    expect(File.exists?(File.join(o_d, shm.sp_output_name))).to be_true
    expect(File.exists?(File.join(o_d, shm.lt_output_name))).to be_true
    expect(File.exists?(File.join(o_d, shm.cr_output_name))).to be_true
    expect(File.size(File.join(o_d, shm.sp_output_name))).to be > 200
    expect(File.size(File.join(o_d, shm.lt_output_name))).to be > 200
    expect(File.size(File.join(o_d, shm.cr_output_name))).to be > 200

    expect(Source.count).to be > 5

    MY_LOG.info "SOURCES:"
    Source.all.each do |s|
      MY_LOG.info "#{s.location} | #{s.user} | #{s.source_type.name}"

      expect(s.location).to be_present
      expect(s.user).to be_present
      expect(s.source_type).to be_present

      expect(s.subject).to be_present if s.parent_id.present?
    end
  end

end
