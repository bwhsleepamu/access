require 'spec_helper'

describe Datum do
  describe "setting associated objects" do
    it "should associate data dictionary" do
      dd = create(:data_dictionary)
      d = Datum.new
      d.data_dictionary = dd

      d.title.should == dd.title
      d.data_dictionary.should == dd
    end

    describe "data values" do
      # value should be used if "multiple" is false
      # value_list should be used if "multiple" is true
      # title needs to be set!!!!
      # if value= used with "multiple" true, call value_list= with array of one
      before do
        @int_dd = create(:integer_dd, multivalue: true)
        @text_dd = create(:text_dd)
        @temp_event = create(:event)
      end

      context "should set data value with value= if multiple values not allowed" do
        it "with new datum" do
          test_val = "this is some value of some sort so deal with it yo"

          d = Datum.new(title: @text_dd.title, event_id: @temp_event.id, value:  test_val)
          d.value.should == test_val
          d.data_values.length.should == 1

          d.should be_valid
          d.save
          d.reload

          d.value.should == test_val
          d.data_values.length.should == 1
        end

        it "with existing datum" do
          test_val2 = "something else"

          d = create(:datum, title: @text_dd.title, event_id: @temp_event.id)

          d.update_attributes(value: test_val2)
          d.value.should == test_val2
          d.data_values.length.should == 1

          d.reload

          d.data_values.length.should == 1
          d.value.should == test_val2
        end
      end

      it "should set data values with values= if multiple values allowed" do
        test_val = 1
        test_val2 = 5
        test_val3 = 44

        d = Datum.new(title: @int_dd.title, event_id: @temp_event.id, values: [test_val, test_val2])
        d.values.should include(test_val)
        d.values.should include(test_val2)
        d.values.should_not include(test_val3)
        d.data_values.length.should == 2

        d.should be_valid
        d.save
        d.reload

        d = Datum.find(d.id)

        d.data_values.length.should == 2
        d.values.should include(test_val)

        d.update_attributes(values: [test_val3])
        d.reload
        d.data_values.length.should == 1
        d.values.first.should == test_val3
      end

    end

    describe "quality flags" do
      # generic hash list options:
        # clear_all:
        # list:
          # quality_flag_id:
          # data_quality_flag_id:
          # delete:
          # description:
          # name:
    end

    describe "source" do
      # generic params:
        # delete:
        # source_id:
        # description:
        # location:
        # source_type_id: (HOW DO WE DEAL WITH THESE?)
        # user_id: (AND THESE?)
    end

    describe "documentation" do
      # generic params:
        # delete:
        # documentation_id:
        # author:
        # description_of_procedure:
        # origin_location:
        # title:
        # user_id: (HOW DO WE DEAL WITH THESE?)



    end


    # USER:
    # SOURCE_TYPE
    #

  end


end
