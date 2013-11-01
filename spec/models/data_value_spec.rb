require 'spec_helper'

describe DataValue do
  describe "constraints" do
    context "One association allowed - either a min value, a max value, an allowed value, or a data value for a datum" do
      it "should raise exception if another association is added" do
        datum = create(:datum, data_dictionary: create(:string_dd))
        data_value = datum.data_values.first
        data_value.datum_id.should == datum.id
        data_value.datum.should == datum

        expect do
          data_value.data_dictionary_as_min_value = create(:numeric_dd)
          data_value.save
        end.to raise_exception
      end
    end
  end

  describe "#value=" do
    it "should put the value in the proper value attribute if type flag is set." do
      data_values = {
          :text => create(:data_value, type_flag: "text_value"),
          :num => create(:data_value, type_flag: "num_value"),
          :dt => create(:data_value, type_flag: "time_value")
      }
      vals = {:text => "sometext", :num => 2342.123, :dt => Time.zone.now()}

      data_values[:text].value = vals[:text]
      data_values[:num].value = vals[:num]
      data_values[:dt].value = vals[:dt]

      data_values[:text].text_value.should == vals[:text]
      data_values[:num].num_value.should == vals[:num]
      data_values[:dt].time_value.should == vals[:dt]
    end

    it "should set proper type flag using associated data type and put the value in the proper attribute if type flag is not set " do
      text_dd = create(:text_dd)
      data_values = {
          :text => create(:data_value, datum: create(:datum, data_dictionary: text_dd)),
          :num => create(:data_value, datum: create(:datum, data_dictionary: create(:integer_dd))),
          :dt => create(:data_value, datum: create(:datum, data_dictionary: create(:time_dd))),
          :av => create(:data_value, data_dictionary_as_allowed_value: [text_dd]),
          :min => create(:data_value, data_dictionary_as_min_value: text_dd),
          :max => create(:data_value, data_dictionary_as_min_value: text_dd)
      }

      vals = {:text => "sometext", :num => 2342.123, :dt => Time.zone.now()}
      data_values[:text].value = vals[:text]
      data_values[:num].value = vals[:num]
      data_values[:dt].value = vals[:dt]
      data_values[:av].value = vals[:text]
      data_values[:min].value = vals[:text]
      data_values[:max].value = vals[:text]

      data_values[:text].text_value.should == vals[:text]
      data_values[:num].num_value.should == vals[:num]
      data_values[:dt].time_value.should == vals[:dt]
      data_values[:av].text_value.should == vals[:text]
      data_values[:min].text_value.should == vals[:text]
      data_values[:max].text_value.should == vals[:text]
    end

    it "should set type flag if type flag not set but association exists" do
      dv = build(:data_value)
      dv.data_dictionary_as_min_value = create(:integer_dd)

      dv.value = 22
      dv.num_value.should == 22
      dv.save
    end

    it "should raise exception if no associated data type" do
      data_value = build(:data_value)
      expect { data_value.value = 324 }.to raise_exception /No type flag set/
    end

    it "should assign value to nil if wrong data type supplied"
      
    end



  describe "#value" do
    it "should return text_value if data flag is of that type." do
      data_value = create(:data_value, type_flag: "text_value")
      data_value.text_value = "test"

      data_value.value.should == data_value.text_value
    end
    it "should return time_value if data flag is of that type." do
      data_value = create(:data_value, type_flag: "time_value")
      data_value.text_value = DateTime.now()

      data_value.value.should == data_value.time_value
    end
    it "should return num_value if data flag is of that type." do
      data_value = create(:data_value, type_flag: "num_value")
      data_value.text_value = 1212.323

      data_value.value.should == data_value.num_value
    end
  end

  describe "#data_type" do
    it "should return data type of any associated data dictionary" do
      dds = {:text => create(:text_dd), :integer => create(:integer_dd), :numeric => create(:numeric_dd), :string => create(:string_dd), :time => create(:time_dd), :datetime => create(:datetime_dd), :date => create(:date_dd), }

      create(:data_value, data_dictionary_as_allowed_value: [dds[:text]]).data_type.name.should == "text_type"
      create(:data_value, data_dictionary_as_allowed_value: [dds[:integer]]).data_type.name.should == "integer_type"
      create(:data_value, data_dictionary_as_allowed_value: [dds[:numeric]]).data_type.name.should == "numeric_type"
      create(:data_value, data_dictionary_as_allowed_value: [dds[:string]]).data_type.name.should == "string_type"
      create(:data_value, data_dictionary_as_allowed_value: [dds[:time]]).data_type.name.should == "time_type"
      create(:data_value, data_dictionary_as_allowed_value: [dds[:datetime]]).data_type.name.should == "datetime_type"
      create(:data_value, data_dictionary_as_allowed_value: [dds[:date]]).data_type.name.should == "date_type"

      create(:data_value, data_dictionary_as_min_value: dds[:text]).data_type.name.should == "text_type"
      create(:data_value, data_dictionary_as_min_value: dds[:integer]).data_type.name.should == "integer_type"
      create(:data_value, data_dictionary_as_min_value: dds[:numeric]).data_type.name.should == "numeric_type"
      create(:data_value, data_dictionary_as_min_value: dds[:string]).data_type.name.should == "string_type"
      create(:data_value, data_dictionary_as_min_value: dds[:time]).data_type.name.should == "time_type"
      create(:data_value, data_dictionary_as_min_value: dds[:datetime]).data_type.name.should == "datetime_type"
      create(:data_value, data_dictionary_as_min_value: dds[:date]).data_type.name.should == "date_type"

      create(:data_value, data_dictionary_as_max_value: dds[:text]).data_type.name.should == "text_type"
      create(:data_value, data_dictionary_as_max_value: dds[:integer]).data_type.name.should == "integer_type"
      create(:data_value, data_dictionary_as_max_value: dds[:numeric]).data_type.name.should == "numeric_type"
      create(:data_value, data_dictionary_as_max_value: dds[:string]).data_type.name.should == "string_type"
      create(:data_value, data_dictionary_as_max_value: dds[:time]).data_type.name.should == "time_type"
      create(:data_value, data_dictionary_as_max_value: dds[:datetime]).data_type.name.should == "datetime_type"
      create(:data_value, data_dictionary_as_max_value: dds[:date]).data_type.name.should == "date_type"
    end

    it "should return data type of associated datum" do
      create(:data_value, datum: create(:datum, data_dictionary: create(:text_dd))).data_type.name.should == "text_type"
      create(:data_value, datum: create(:datum, data_dictionary: create(:integer_dd))).data_type.name.should == "integer_type"
      create(:data_value, datum: create(:datum, data_dictionary: create(:numeric_dd))).data_type.name.should == "numeric_type"
      create(:data_value, datum: create(:datum, data_dictionary: create(:string_dd))).data_type.name.should == "string_type"
      create(:data_value, datum: create(:datum, data_dictionary: create(:time_dd))).data_type.name.should == "time_type"
      create(:data_value, datum: create(:datum, data_dictionary: create(:datetime_dd))).data_type.name.should == "datetime_type"
      create(:data_value, datum: create(:datum, data_dictionary: create(:date_dd))).data_type.name.should == "date_type"
    end

    it "should return nil if no associated type" do
      build(:data_value).data_type.should be_nil
    end

    it "should raise error if more than one association of one type" do
      tdd = create(:text_dd)
      ndd = create(:numeric_dd)

      expect { create(:data_value, data_dictionary_as_allowed_value: [tdd, ndd]) }.to raise_exception /only allowed to belong to one association/
    end

    it "should raise error if more than one type of association" do
      text_dd = create(:text_dd)
      date_dd = create(:date_dd)
      expect { create(:data_value, data_dictionary_as_allowed_value: [text_dd], datum: create(:datum, data_dictionary: text_dd)) }.to raise_exception /only allowed to belong to one association/
      expect { create(:data_value, data_dictionary_as_min_value: text_dd, datum: create(:datum, data_dictionary: text_dd)) }.to raise_exception /only allowed to belong to one association/
      expect { create(:data_value, data_dictionary_as_max_value: date_dd, datum: create(:datum, data_dictionary: text_dd)) }.to raise_exception /only allowed to belong to one association/
      expect { create(:data_value, data_dictionary_as_allowed_value: [text_dd], data_dictionary_as_max_value: date_dd) }.to raise_exception /only allowed to belong to one association/
      expect { create(:data_value, data_dictionary_as_min_value: date_dd, data_dictionary_as_max_value: date_dd) }.to raise_exception /only allowed to belong to one association/
      expect { create(:data_value, data_dictionary_as_allowed_value: [text_dd], data_dictionary_as_min_value: date_dd) }.to raise_exception /only allowed to belong to one association/
    end
  end

end
