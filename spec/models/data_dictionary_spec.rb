require 'spec_helper'

describe DataDictionary do
  let(:dd) {create(:integer_dd)}
  let(:unsaved_dd) { build(:integer_dd)}
  describe "allowed value assignments" do
    describe "for new data dictionary" do
      it "should save allowed values from array of strings" do
        vals = %w(1 2 3 4 5)
        uninit_dd = DataDictionary.new
        uninit_dd.allowed_values.should be_nil
        uninit_dd.allowed_values?.should be_false

        unsaved_dd.allowed_values.should be_nil
        unsaved_dd.allowed_values?.should be_false
        unsaved_dd.allowed_values = vals
        unsaved_dd.allowed_values.collect{|av| av.to_i.to_s}.should == vals

        unsaved_dd.save
        unsaved_dd.reload
        unsaved_dd.allowed_data_values.length.should == vals.length
        unsaved_dd.allowed_data_values.each do |v|
          expect(v).not_to be_new_record
          expect(v.data_type).to eq(unsaved_dd.data_type)
          v.type_flag.should == unsaved_dd.data_type.storage

          vals.should include(v.value.to_i.to_s)
        end
        unsaved_dd.allowed_values.collect{|av| av.to_i.to_s}.should == vals
      end
    end

    describe "for existing data dictionary" do
      it "should save allowed values from array of strings" do
        vals = %w(1 2 3 4 5)
        dd.allowed_values.should be_nil
        dd.allowed_values?.should be_false
        dd.allowed_values = vals
        dd.allowed_values.collect{|av| av.to_i.to_s}.should == vals

        dd.save
        dd.reload
        dd.allowed_data_values.length.should == vals.length
        dd.allowed_data_values.each do |v|
          v.data_type.should == dd.data_type
          v.type_flag.should == dd.data_type.storage

          vals.should include(v.value.to_i.to_s)
        end
        dd.allowed_values.collect{|av| av.to_i.to_s}.should == vals
      end

    end

    it "should not save allowed values that are empty" do
      vals = [""]
      dd.allowed_values.should be_nil
      dd.allowed_values?.should be_false
      dd.allowed_values = vals

      dd.allowed_values.should be_nil
      dd.save
      dd.reload
      dd.allowed_data_values.length.should == 0

      vals = ["", "1"]
      dd.allowed_values.should be_nil
      dd.allowed_values?.should be_false
      dd.allowed_values = vals

      dd.allowed_data_values.length.should == 1
    end
  end

  describe "min and max value assignments" do

    it "should set values for existing data dictionaries" do
      dd.max_value.should be_nil
      dd.max_value?.should be_false
      dd.min_value.should be_nil
      dd.min_value?.should be_false

      dd.max_value = 10
      dd.min_value = 0

      dd.max_value.should == 10
      dd.min_value.should == 0

      dd.save
      dd.reload

      dd.max_value.should == 10
      dd.min_value.should == 0

      [dd.max_data_value, dd.min_data_value].each do |o|
        o.data_type.should == dd.data_type
        o.type_flag.should == dd.data_type.storage
      end

    end

    it "should set values for new data dictionaries" do
      uninit_dd = DataDictionary.new
      uninit_dd.max_value.should be_nil
      uninit_dd.max_value?.should be_false
      uninit_dd.min_value.should be_nil
      uninit_dd.min_value?.should be_false

      unsaved_dd.max_value.should be_nil
      unsaved_dd.max_value?.should be_false
      unsaved_dd.min_value.should be_nil
      unsaved_dd.min_value?.should be_false

      unsaved_dd.max_value = 10
      unsaved_dd.min_value = 0


      unsaved_dd.max_value.should == 10
      unsaved_dd.min_value.should == 0

      [unsaved_dd.min_data_value].each do |o|
        o.data_type.should == unsaved_dd.data_type
        o.type_flag.should == unsaved_dd.data_type.storage
      end

      unsaved_dd.save
      unsaved_dd.reload


      unsaved_dd.max_value.should == 10
      unsaved_dd.min_value.should == 0

      [unsaved_dd.min_data_value].each do |o|
        o.data_type.should == unsaved_dd.data_type
        o.type_flag.should == unsaved_dd.data_type.storage
      end

    end

    it "should set and update values from params hash" do
      dt = create(:integer_type)
      attrs = {"title"=>"suite_number", "description"=>"The number of the suite (usually on 9B) where the subject was housed during their study.", "data_type_id"=>dt.id, "min_value"=>"0", "min_value_inclusive"=>"1", "max_value"=>"5", "max_value_inclusive"=>"1", "multivalue"=>"0", "unit"=>"", "allowed_values"=>[""]}
      attrs2 = {"title"=>"suite_number", "description"=>"The number of the suite (usually on 9B) where the subject was housed during their study.", "data_type_id"=>dt.id, "min_value"=>"5", "min_value_inclusive"=>"0", "max_value"=>"10", "max_value_inclusive"=>"1", "multivalue"=>"0", "unit"=>"", "allowed_values"=>[""]}

      dd = DataDictionary.new(attrs)

      dd.max_value.should == 5
      dd.max_value?.should be_true
      dd.min_value.should == 0
      dd.min_value?.should be_true
      dd.min_value_inclusive.should be_true
      dd.max_value_inclusive.should be_true

      dd.save.should be_true
      dd = DataDictionary.find(dd.id)

      dd.max_value.should == 5
      dd.max_value?.should be_true
      dd.min_value.should == 0
      dd.min_value?.should be_true
      dd.min_value_inclusive.should be_true
      dd.max_value_inclusive.should be_true

      dd.logged_update(attrs2).should be_true
      dd = DataDictionary.find(dd.id)

      expect(dd.max_value.to_i).to eq(10)
      dd.max_value?.should be_true
      expect(dd.min_value.to_i).to eq(5)
      dd.min_value?.should be_true
      dd.min_value_inclusive.should be_false
      dd.max_value_inclusive.should be_true
    end
  end
end
