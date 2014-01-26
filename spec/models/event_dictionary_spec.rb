require 'spec_helper'

describe EventDictionary do

  describe "#event_data_query_sql" do
    before do
      @ed_name = "ed_1"
      @ed2_name = "ed_2"

      @paired_sql = %(select
          s.id subject_id,
          s.subject_code subject_code,
          max( decode(e.name, '#{@ed_name}', e.name)) first_event_name,
          max( decode(e.name, '#{@ed_name}', labtime_hour)) first_labtime_hour,
          max( decode(e.name, '#{@ed_name}', labtime_min)) first_labtime_min,
          max( decode(e.name, '#{@ed_name}', labtime_sec)) first_labtime_sec,
          max( decode(e.name, '#{@ed_name}', labtime_year)) first_labtime_year,
          max( decode(e.name, '#{@ed_name}', labtime_decimal(e.labtime_hour, e.labtime_min, e.labtime_sec))) first_decimal_labtime,
          max( decode(e.name, '#{@ed_name}', realtime)) first_realtime,
          max( decode(e.name, '#{@ed2_name}', e.name)) second_event_name,
          max( decode(e.name, '#{@ed2_name}', labtime_hour)) second_labtime_hour,
          max( decode(e.name, '#{@ed2_name}', labtime_min)) second_labtime_min,
          max( decode(e.name, '#{@ed2_name}', labtime_sec)) second_labtime_sec,
          max( decode(e.name, '#{@ed2_name}', labtime_year)) second_labtime_year,
          max( decode(e.name, '#{@ed2_name}', labtime_decimal(e.labtime_hour, e.labtime_min, e.labtime_sec))) second_decimal_labtime,
          max( decode(e.name, '#{@ed2_name}', realtime)) second_realtime,
          max( decode( d.title, 'type', text_value)) type,
          max( decode( d.title, 'count', num_value)) count
        from events e
          join subjects s on s.id = e.subject_id
          left join data d on d.event_id = e.id
          left join data_values dv on d.id = dv.datum_id
          join subjects_subject_groups ssg on ssg.subject_id = s.id
          join subject_groups sg on sg.id = ssg.subject_group_id
        where
          (e.name = '#{@ed_name}' or e.name = '#{@ed2_name}')
        group by s.id, s.subject_code, e.group_label
        order by s.subject_code, first_decimal_labtime).strip.gsub(/\s+/, ' ')

      @single_sql = %(select
          s.id subject_id,
          s.subject_code subject_code,
          max(e.name) event_name,
          max(e.labtime_hour) labtime_hour,
          max(e.labtime_min) labtime_min,
          max(e.labtime_sec) labtime_sec,
          max(e.labtime_year) labtime_year,
          max(labtime_decimal(e.labtime_hour, e.labtime_min, e.labtime_sec)) decimal_labtime,
          max(e.realtime) realtime,
          max( decode( d.title, 'type', text_value)) type,
          max( decode( d.title, 'count', num_value)) count
        from events e
          join subjects s on s.id = e.subject_id
          left join data d on d.event_id = e.id
          left join data_values dv on d.id = dv.datum_id
          join subjects_subject_groups ssg on ssg.subject_id = s.id
          join subject_groups sg on sg.id = ssg.subject_group_id
        where
          (e.name = '#{@ed_name}')
        group by s.id, s.subject_code, e.id
        order by s.subject_code, decimal_labtime).strip.gsub(/\s+/, ' ')
    end
    
    it "should create sql for a unpaired event dictionary" do
      st = create(:string_type)
      it = create(:integer_type)

      dd1 = DataDictionary.new(title: "type", data_type: st)
      dd2 = DataDictionary.new(title: "count", data_type: it)

      expect(dd1.save).to be_true
      expect(dd2.save).to be_true

      ed = EventDictionary.new(name: @ed_name)
      ed.data_dictionary = [dd1, dd2]
      expect(ed.save).to be_true

      expect(ed.event_data_query_sql).to eq(@single_sql)
    end
    

    it "should create paired sql for a paired event dictionary, unless 'ignore_paired' flag is set" do
      st = create(:string_type)
      it = create(:integer_type)

      dd1 = DataDictionary.new(title: "type", data_type: st)
      dd2 = DataDictionary.new(title: "count", data_type: it)

      expect(dd1.save).to be_true
      expect(dd2.save).to be_true

      ed = EventDictionary.new(name: @ed_name)
      ed2 = EventDictionary.new(name: @ed2_name)
      ed.data_dictionary = [dd1, dd2]

      expect(ed.save).to be_true
      expect(ed2.save).to be_true

      ed.update_attribute(:paired_id, ed2.id)
      ed2.update_attribute(:paired_id, ed.id)
      ed.reload
      ed2.reload

      expect(ed.paired_event_dictionary).to eq ed2
      expect(ed2.paired_event_dictionary).to eq ed

      expect(ed.event_data_query_sql).to eq(@paired_sql)
      expect(ed.event_data_query_sql({ignore_paired: true})).to eq(@single_sql)

    end

    it "should create subject-specific and subject-group-specific sql" do
      sg = create(:subject_group_with_subjects, subject_count: 2)
      s = sg.subjects.first

      st = create(:string_type)
      it = create(:integer_type)

      dd1 = DataDictionary.new(title: "type", data_type: st)
      dd2 = DataDictionary.new(title: "count", data_type: it)

      expect(dd1.save).to be_true
      expect(dd2.save).to be_true

      ed = EventDictionary.new(name: @ed_name)
      ed.data_dictionary = [dd1, dd2]
      expect(ed.save).to be_true

      expect(ed.event_data_query_sql({subject_group_name: sg.name})).to include("sg.name = '#{sg.name}'")
      expect(ed.event_data_query_sql({subject_code: s.subject_code})).to include("s.subject_code = '#{s.subject_code}'")

    end

  end
end