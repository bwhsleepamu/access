class Labtime
  include Comparable

  attr_accessor :year, :hour, :min, :sec, :time_zone
  DEFAULT_TIME_ZONE = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")

  # Class Methods
  def self.parse(realtime)
    # Return nil if nil parameter
    return nil if realtime.nil?

    # Make sure datetime is an ActiveSupport:TimeWithZone object
    unless realtime.is_a?(ActiveSupport::TimeWithZone)
      raise ArgumentError, "realtime class #{realtime.class} is not ActiveSupport::TimeWithZone" 
    end

    year = realtime.year

    # Use the start of the given year as a reference for finding Labtime
    Time.zone = realtime.time_zone
    reference_time = Time.zone.local(year)

    # find difference between the reference time and the time sent to the method
    difference_in_seconds = realtime.to_i - reference_time.to_i

    # convert difference in seconds to labtime
    hour = difference_in_seconds / 3600
    min = (difference_in_seconds - (hour * 3600)) / 60
    sec = (difference_in_seconds - (hour * 3600) - (min * 60))


    self.new(year, hour, min, sec, realtime.time_zone)
  end

  def self.from_decimal(decimal_labtime, year, time_zone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)"))
    raise ArguementError, "No year supplied!" if year.blank?

    hour = decimal_labtime.to_i
    remainder = decimal_labtime - hour.to_f

    minute_labtime = 6.0 * remainder
    minute = minute_labtime.to_i

    remainder = minute_labtime - minute.to_f
    sec = (60 * remainder).round.to_i

    self.new(year, hour, minute, sec, time_zone)
  end

  def self.from_seconds(sec_time, year, time_zone = DEFAULT_TIME_ZONE)
    hour = (sec_time / 3600.0).to_i
    sec_time = sec_time - (hour * 3600)
    min = (sec_time / 60.0).to_i
    sec_time = sec_time - (min * 60)
    sec = sec_time

    self.new(year, hour, min, sec, time_zone)
  end

  def self.from_s(str, time_params = {}, time_zone = DEFAULT_TIME_ZONE)
    time_captures = /(\d+)\:(\d{1,2})(\:(\d{1,2}))?(\s(\d\d\d\d))?\z/.match(str).captures

    time_params[:hour] ||= time_captures[0]
    time_params[:min] ||= time_captures[1]
    time_params[:sec] ||= time_captures[3]
    time_params[:year] ||= time_captures[5]

    self.new(time_params[:year], time_params[:hour], time_params[:min], time_params[:sec], time_zone)
  end

  # Constructor
  def initialize(year, hour, min, sec, time_zone = nil)
    @year = year.to_i
    @hour = hour.to_i
    @min = min.to_i
    @sec = sec.to_i
    @time_zone = time_zone || DEFAULT_TIME_ZONE
  end

  # Convert Labtime to real time
  def to_time
    reference_time = time_zone.local(year)
    reference_time + time_in_seconds
  end

  # For Comparable
  def <=>(other)
    to_time <=> other.to_time
  end

  def to_s
    "#{year} #{hour}:#{min}:#{sec} #{time_zone.to_s}"
  end

  def to_short_s
    "#{hour}:#{min}:#{sec}"
  end

  def time_in_seconds
    hour * 3600 + min * 60 + sec
  end

  def add_seconds(sec)
    self.class.from_seconds(self.time_in_seconds + sec, self.year, self.time_zone)
  end

  def to_decimal
    hour.to_f + (min.to_f/60.0) + (sec.to_f/3600.0)
  end

  private

end