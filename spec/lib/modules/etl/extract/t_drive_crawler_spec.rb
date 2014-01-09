require 'spec_helper'

describe ETL::TDriveCrawler do
  describe "#populate_t_drive_location" do
    it "should work in the base case" do
      root_path = "/usr/local/htdocs/access/spec/data/sh_file_merger/t_drive_dir"

      same_loc_subject = create(:subject, subject_code: '1812W', t_drive_location: '/usr/local/htdocs/access/spec/data/sh_file_merger/t_drive_dir/some_dir/1812W')
      different_loc_subject = create(:subject, subject_code: '1983W', t_drive_location: '/usr/local/htdocs/access/spec/data/sh_file_merger/t_drive_dir/some_other_dir/1983W')
      new_loc_subject = create(:subject, subject_code: '1983WP1')
      double_loc_subject = create(:subject, subject_code: '18G1W')
      another_subject = create(:subject, subject_code: '1916W')
      no_loc_subject = create(:subject, subject_code: '1715W')

      sg = SubjectGroup.new(name: 'crawler_subjects')
      sg.subjects << [same_loc_subject, different_loc_subject, new_loc_subject, double_loc_subject, another_subject, no_loc_subject]
      expect(sg.save).to be_true

      r = ETL::TDriveCrawler.populate_t_drive_location(sg, root_path)

      expect(r[:none_found]).to include(no_loc_subject.subject_code)
      expect(r[:locations_same]).to include(same_loc_subject.subject_code)
      expect(r[:locations_differ]).to include(different_loc_subject.subject_code)
      expect(r[:multiple_found]).to include(double_loc_subject.subject_code)
      expect(r[:new_set]).to include(new_loc_subject.subject_code)
      expect(r[:new_set]).to include(another_subject.subject_code)
    end
  end

end
