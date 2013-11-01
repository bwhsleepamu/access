require 'spec_helper'
require 'fileutils'

describe ETL::NewFormsLoader do
  before do
    @merged_dir = "spec/data/merged_dbf"
    @doc = create(:documentation)
    @source_type = create(:source_type)
    @user = create(:user)
    create(:dbf_loader_dictionaries)
    MY_LOG.info EventDictionary.all.map(&:name)
    FileUtils.rm_r @merged_dir
    FileUtils.mkdir @merged_dir
  end
  describe "new file format" do
    before do
      @subjects = [
          create(:subject, subject_code: "3227GX", admit_date: Time.zone.local(2012, 3, 4)),
          create(:subject, subject_code: "3228GX", admit_date: Time.zone.local(2012, 3, 4)),
          create(:subject, subject_code: "3232GX", admit_date: Time.zone.local(2012, 3, 4)),
          create(:subject, subject_code: "3233GX", admit_date: Time.zone.local(2012, 3, 4)),
          create(:subject, subject_code: "3237GX", admit_date: Time.zone.local(2012, 3, 4)),
      ]
      @sg = create(:subject_group, subject_ids: @subjects[1..2].map(&:id))
    end

    it "should load all files for a given subject group" do
      @sg.subjects.length.should == 2
      new_forms_loader = ETL::NewFormsLoader.new("/home/pwm4/Windows/tdrive/IPM/CSR_32d_FD_20h", @merged_dir, @sg, @doc, @source_type, @user)

      new_forms_loader.search_root
      new_forms_loader.merge_files
      new_forms_loader.load_events

      Event.select(:name).uniq.sort.map(&:name).should == EventDictionary.all.map(&:name).sort
      Source.count.should == 2
      Event.count.should > 1000

    end

  end
  describe "old file format" do
    before do
      @subject = create(:subject, subject_code: "25Q1VS", admit_date: Time.zone.local(2005, 3, 4))
      @sg = create(:subject_group, subject_ids: [@subject.id])
    end

    it "should work for older NewForms" do
      new_forms_loader = ETL::NewFormsLoader.new("/home/pwm4/Windows/tdrive/IPM/NSBRI_71d_Entrainment", "spec/data/merged_dbf", @sg, @doc, @source_type, @user)

      new_forms_loader.search_root
      new_forms_loader.merge_files
      new_forms_loader.load_events

      Source.count.should == 1
      Event.count.should > 500
    end

    it "should not duplicate objects" do
      new_forms_loader = ETL::NewFormsLoader.new("/home/pwm4/Windows/tdrive/IPM/NSBRI_71d_Entrainment", "spec/data/merged_dbf", @sg, @doc, @source_type, @user)
      new_forms_loader.search_root
      new_forms_loader.merge_files
      new_forms_loader.load_events

      counts = {sources: Source.count, events: Event.count}
      counts[:sources].should == 1
      counts[:events].should > 100

      new_forms_loader = ETL::NewFormsLoader.new("/home/pwm4/Windows/tdrive/IPM/NSBRI_71d_Entrainment", "spec/data/merged_dbf", @sg, @doc, @source_type, @user)
      new_forms_loader.search_root
      new_forms_loader.merge_files
      new_forms_loader.load_events

      new_counts = {sources: Source.count, events: Event.count}
      new_counts.should == counts
    end
  end
end