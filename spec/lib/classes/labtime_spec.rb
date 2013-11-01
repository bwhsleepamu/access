require 'spec_helper'

describe Labtime do
  def times_equal?(labtime, time_hash)
    labtime.year == time_hash[:year] && labtime.hour == time_hash[:hour] && labtime.min == time_hash[:min] && labtime.sec == time_hash[:sec]
  end

  before do
    # These two represent the same time
    @valid_labtime_params = { :year => 2005, :hour => 1000, :min => 33, :sec => 20 }

    Time.zone = "Eastern Time (US & Canada)"
    @valid_realtime = Time.zone.local(2005, 2, 11, 16, 33, 20)

    Time.zone = "Hawaii"
    @different_timezone_time = Time.zone.local(2005, 2, 11, 16, 33, 20)
  end

  it "should covert between real time and labtime seamlessly" do
    labtime = Labtime.parse(@valid_realtime)
    realtime = labtime.to_time
    realtime.should == @valid_realtime

    labtime = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])
    realtime = labtime.to_time
    labtime_2 = Labtime.parse(realtime)
    labtime.should == labtime_2
  end

  describe "Labtime.parse" do
    it "should return a Labtime instance corresponding to a given ActiveSupport::TimeWithZone." do
      parsed_time = Labtime.parse(@valid_realtime)
      times_equal?(parsed_time, @valid_labtime_params).should be_true
    end

    it "should set time zone of Labtime to time zone of given DateTime and set the correct Labtime" do
      t1 = Labtime.parse(@valid_realtime)
      t2 = Labtime.parse(@different_timezone_time)

      puts "t1: #{t1.to_s} t2: #{t2.to_s}"
      times_equal?(t1, @valid_labtime_params).should be_true
      times_equal?(t2, @valid_labtime_params).should be_true

      t1.time_zone == @valid_realtime.time_zone
      t2.time_zone == @different_timezone_time.time_zone
    end

    it "should raise exception if parameter is not of type ActiveSupport::TimeWithZone" do
      invalid_param = DateTime.now()
      valid_param = @valid_realtime

      expect {Labtime.parse(valid_param)}.to_not raise_error
      expect {Labtime.parse(invalid_param)}.to raise_error
    end

    it "should return nil if realtime is nil" do
      Labtime.parse(nil).should be_nil
    end

  end

  describe "dst compliance" do
    it "should create the correct labtime in and out of dst" do
      t = Time.zone.local(2012, 3, 10, 20, 0, 0)
      t2 = t + 7.hours

      l = Labtime.parse(t)
      l2 = Labtime.parse(t2)

      (l2.hour - l.hour).should == 7
    end
  end

  describe "#initialize" do
    let(:labtime) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])}

    it "should create new labtime instance with year, hour, minute, and second." do
      labtime.should_not be_nil
      times_equal?(labtime, @valid_labtime_params).should be_true
    end

    it "should have a default timezone of Eastern Time" do
      labtime.time_zone.to_s.should == "(GMT-05:00) Eastern Time (US & Canada)"
      labtime.time_zone.should be_a_kind_of(ActiveSupport::TimeZone)
    end
  end

  describe "#to_time" do
    let(:labtime) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])}

    it "should return Time object corresponding to given labtime." do
      realtime = labtime.to_time
      realtime.should be_an_instance_of(ActiveSupport::TimeWithZone)
      realtime.time_zone.should == labtime.time_zone
      realtime.should == @valid_realtime
    end

  end

  describe "#to_s" do
    let(:labtime) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])}

    it "should return a formatted labtime string of year hour:min:sec time_zone" do
      labtime.to_s.should be_a_kind_of(String)
    end
  end

  describe "#to_decimal" do
    let(:labtime) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])}
    it "should return decimal conversion of labtime" do
      labtime.to_decimal.should == 1000.0 + 33/60.0 + 20/3600.0
    end
  end

  describe "#from_decimal" do
    let(:labtime) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])}

    it "should inter-convert decimal and labtime" do
      l = Labtime.from_decimal(labtime.to_decimal, labtime.year, labtime.time_zone)
      l.should == labtime
    end
  end

  describe "#from_s" do
    let(:labtime) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])}
    let(:labtime_no_sec) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], 0) }

    it "should convert from string" do
      l = Labtime.from_s("#{labtime_no_sec.hour}:#{labtime_no_sec.min}", { year: labtime_no_sec.year })
      l.should == labtime_no_sec

      l = Labtime.from_s("#{labtime.hour}:#{labtime.min}:#{labtime.sec}", { year: labtime.year })
      l.should == labtime

      l = Labtime.from_s("#{labtime_no_sec.hour}:#{labtime_no_sec.min} #{labtime_no_sec.year}")
      l.should == labtime_no_sec

      l = Labtime.from_s("#{labtime.hour}:#{labtime.min}:#{labtime.sec} #{labtime.year}")
      l.should == labtime

      l = Labtime.from_s("#{labtime.hour}:#{labtime.min}", { year: labtime.year, sec: labtime.sec })
      l.should == labtime

    end
  end

  describe "#from_seconds" do
    let(:labtime) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])}
    it "should interconvert with labtime.time_in_seconds" do
      l = Labtime.from_seconds(labtime.time_in_seconds, labtime.year, labtime.time_zone)
      l.should == labtime
    end

  end

  describe "#add_seconds" do
    let(:labtime) { Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])}
    it "should work the same as adding seconds to realtime and converting" do
      secs = 1233
      rt = labtime.to_time
      nrt = rt + secs.seconds

      labtime.add_seconds(secs).should == Labtime.parse(nrt)
    end
  end

  describe "<=>" do
    it "should return 0 for identical labtimes" do
      l1 = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])
      l2 = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])

      (l1 <=> l2).should == 0
    end

    it "should return -1 when comparing to later labtime" do
      l1 = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])
      l2 = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour] + 1, @valid_labtime_params[:min], @valid_labtime_params[:sec])

      (l1 <=> l2).should == -1
    end

    it "should return 1 when comparing to earlier labtime" do
      l1 = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec])
      l2 = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min] - 1, @valid_labtime_params[:sec])

      (l1 <=> l2).should == 1
    end

    it "should return -1 when comparing to same labtime in a timezone with a larger offset" do
      zone1 = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
      zone2 = ActiveSupport::TimeZone.new("Hawaii")

      l1 = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min], @valid_labtime_params[:sec], zone1)
      l2 = Labtime.new(@valid_labtime_params[:year], @valid_labtime_params[:hour], @valid_labtime_params[:min] - 1, @valid_labtime_params[:sec], zone2)

      (l1 <=> l2).should == -1
    end
  end
end