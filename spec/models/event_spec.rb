require 'spec_helper'

describe Event do

  describe "self.list_intervals" do
    it "should collapse matching endpoints and their data into one row" do
      create(:interval_list_dictionaries)
      ed1 = EventDictionary.find_by_name("lighting_block_start_scheduled")
      ed2 = EventDictionary.find_by_name("lighting_block_end_scheduled")

      t = Time.zone.now()
      s = create(:subject)
      source = create(:source)
      documentation = create(:documentation)

      1..100.times do |x|
        Event.direct_create(name: "lighting_block_start_scheduled", subject_id: s.id, source_id: source.id, documentation_id: documentation.id, realtime: (t + x.hours), data_list: {clear_all: 0, list: [{title: "light_level", value: Random.rand(2000) }]}, event_dictionary: ed1, group_label: x)
        Event.direct_create(name: "lighting_block_end_scheduled", subject_id: s.id, source_id: source.id, documentation_id: documentation.id, realtime: (t + x.hours + 30.minutes), event_dictionary: ed2, group_label: x)
      end

      Event.count.should == 200

      list = Event.interval_list(s, ed1, ed2)

      list.length.should == 100
    end
  end

  describe "self.continuous_list" do

  end

  describe "self.interval_list" do

  end

  describe "self.direct_create" do
    it "should insert new event and all related data and data values into database" do
      ed = create(:subject_vitals)
      source = create(:source)
      documentation = create(:documentation)
      user = create(:user)
      s = create(:subject)
      realtime = Time.zone.now
      labtime = Labtime.parse(realtime)

      data_params = {clear_all: 0, list: []}
      ed.data_dictionary.each do |dd|
        data_params[:list] << {title: dd.title, value: Random.rand(20)}
      end

      params = {name: ed.name, subject_id: s.id, source_id: source.id, documentation_id: documentation.id, realtime: realtime, data_list: data_params, event_dictionary: ed }
      Event.direct_create(params)

      Event.where(name: params[:name]).count.should == 1
      e = Event.where(name: params[:name]).first
      e.data.length.should == 3


    end

  end

  describe "self.hard_delete" do
    it "should completely delete event and related data/data_values of a given name for the given subject" do
      c = 10
      ed = create(:event_dictionary_with_data_records)
      ed2 = create(:event_dictionary)
      s = create(:subject)
      events = create_list(:event_from_dictionary, c, name: ed.name, subject: s)
      events = create_list(:event_from_dictionary, c, name: ed2.name, subject: s)
      Event.count.should == c*2
      Event.where(name: ed.name).count.should == c
      Event.hard_delete s, ed.name
      Event.count.should == c
      Event.where(name: ed.name).count.should == 0
    end
  end



  describe "#create" do
     it "should not create event if not defined in event dictionary" do
       template = build(:event)

       event = Event.new(name: template.name, realtime: template.realtime)
       event.save
       event.should be_new_record
     end

     context "event times" do
       before do
         @realtime = Time.zone.now.round(0)
         @labtime = Labtime.parse(@realtime)
       end

       it "should set labtime if realtime provided and realtime if labtime provided" do
         event = create(:event, realtime: @realtime)
         event.labtime.should == @labtime

         event = create(:event, labtime: @labtime)
         event.realtime.to_i.should == @realtime.to_i
       end

       # TODO: IS THIS NEEDED? One will always override the other, which is the only problem...should we just make sure both are not in params? idk idk...for now leave it out
       #it "should throw exception if both types of times are provided but do not match up" do
       #  later_labtime = Labtime.new(@labtime.year, @labtime.hour, @labtime.min, @labtime.sec - 1, @labtime.time_zone)
       #  expect { create(:event, realtime: @realtime, labtime: later_labtime) }.to raise_exception /labtime and realtime both set but do not match/
       #end

       it "should update labtime if realtime is set at some point" do
         event = create(:event, realtime: @realtime)
         later_realtime = @realtime + 1.hour
         event.realtime = later_realtime

         event.should be_valid
         event.save
         event.realtime.should == later_realtime
         event.labtime.should == Labtime.parse(later_realtime)
       end

       it "should update realtime if labtime is set at some point" do
         event = create(:event, labtime: @labtime)
         later_labtime = Labtime.new(@labtime.year, @labtime.hour, @labtime.min, @labtime.sec - 1, @labtime.time_zone)
         event.labtime = later_labtime
         event.should be_valid
         event.save
       end
     end
  end

  describe "data_list=" do
     # title
     # value
     # notes
     it "should create new data objects for built event" do
       ed = create(:event_dictionary_with_data_records)
       values = ed.data_dictionary.length.times.map{|x| "value#{x}"}

       dl = []

       ed.data_dictionary.each_with_index do |dd, i|
         dl << {title: dd.title, value: values[i], notes: "something"}
       end

       event = build(:event, name: ed.name)

       event.data_list = {clear_all: "0", list: dl}

       event.data.length.should == ed.data_dictionary.length
       event.data.each {|d| values.should include(d.value)}

       event.save

       event.data.length.should == ed.data_dictionary.length
       event.data.each {|d| values.should include(d.value)}
     end

     it "should not create data object if title not defined in event dictionary" do
       ed = create(:event_dictionary_with_data_records)
       dl = []

       ed.data_dictionary.each_with_index do |dd, i|
         dl << {title: dd.title, value: "value_#{i}", notes: "something"}
       end

       create(:data_dictionary, title: "some_other_title")
       dl << {title: "some_other_title", value: "should not be saved"}

       event = build(:event, name: ed.name)
       event.data_list = {list: dl}

       event.data.length.should == ed.data_dictionary.length

     end

     it "should update data object if one of given title already exists" do
       ed = create(:event_dictionary_with_data_records)
       new_val = "testoutnew"
       new_val2 = "testoutnew2"

       dl = []

       ed.data_dictionary.each_with_index do |dd, i|
         dl << {title: dd.title, value: "value_#{i}", notes: "something"}
       end

       event = build(:event, name: ed.name, data_list: {list: dl}, realtime: Time.zone.now, labtime: nil)
       title_to_update = event.data.first.title
       datum_to_update = event.data.select{|d| d.title == title_to_update}.first
       event.data_list = {list: [{title: title_to_update, value: new_val}]}

       event.data.length.should == ed.data_dictionary.length
       datum_to_update.value.should == new_val

       MY_LOG.info "#{event.valid?} #{event.errors.full_messages}"
       event.should be_valid
       event.save


       datum_to_update = event.data.select{|d| d.title == title_to_update}.first
       datum_to_update.id.should_not be_nil
       datum_to_update.value.should == new_val

       event.data_list = {list: [{title: datum_to_update.title, value: new_val2}]}
       event.data.length.should == ed.data_dictionary.length
       datum_to_update.reload
       datum_to_update.value.should == new_val2
     end

     it "should clear all data if clear_all flag selected" do
       pending "do soon!"
     end

     it "should delete and/or not add datum if delete flag selected" do
       pending "do soon!"
     end
  end

  context "labtimes" do
     before do
       @realtime = Time.zone.now
       @labtime = Labtime.parse(@realtime)
     end

     describe "#labtime" do
       it "should return a labtime object corresponding to labtime fields" do
         event = create(:event, labtime_year: @labtime.year, labtime_hour: @labtime.hour, labtime_min: @labtime.min, labtime_sec: @labtime.sec, labtime_timezone: @labtime.time_zone.name)

         event.labtime.should == @labtime
       end

       it "should return nil if one field is nil" do
         events = []
         events[0] = build(:event, labtime_hour: @labtime.hour, labtime_min: @labtime.min, labtime_sec: @labtime.sec)
         events[1] = build(:event, labtime_year: @labtime.year, labtime_min: @labtime.min, labtime_sec: @labtime.sec)
         events[2] = build(:event, labtime_year: @labtime.year, labtime_hour: @labtime.hour, labtime_sec: @labtime.sec)
         events[3] = build(:event, labtime_year: @labtime.year, labtime_hour: @labtime.hour, labtime_min: @labtime.min)

         events.each do |event|
           event.labtime.should be_nil
         end

       end
     end
     describe "#labtime=" do
       it "should set labtime fields given the labtime object" do
         event = create(:event)

         event.labtime = @labtime
         event.labtime_year.should == @labtime.year
         event.labtime_hour.should == @labtime.hour
         event.labtime_min.should == @labtime.min
         event.labtime_sec.should == @labtime.sec
         event.labtime_timezone.should == @labtime.time_zone.name
       end
     end
  end
end
