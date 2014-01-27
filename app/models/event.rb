class Event < ActiveRecord::Base
  ##
  # Associations
  has_many :data, autosave: true, dependent: :delete_all
  has_many :quality_flags, :through => :event_quality_flags
  has_many :event_quality_flags
  belongs_to :documentation
  belongs_to :source
  belongs_to :subject

  ##
  # Attributes
  #attr_accessible :documentation_id, :group_label, :name, :notes, :realtime, :source_id, :subject_id, :labtime, :data_list

  ##
  # Callbacks
  before_save :synchronize_times

  ##
  # Concerns
  include Loggable, Deletable, Indexable

  ##
  # Database Settings


  ##
  # Scopes
  scope :search, lambda { |term| search_scope([:name], term) }

  ##
  # Validations
  validate :name_has_to_be_defined_in_dictionary, :time_must_be_defined
  validates_presence_of :name, :subject_id

  ##
  # Variables

  ##
  # Class Methods
  def self.generate_report(name, attrs = {})
    attrs = { ignore_paired: false }.merge attrs
    ed = EventDictionary.find_by_name name
    sql = ed.event_data_query_sql(attrs)

    {sql: sql, result: Event.connection.exec_query(sql)}
  end

  def self.continuous_list(subject, event_record, options = {use_materialized_view: true, refresh: false, recreate: false})

    event_name = event_record.name

    data_query = []
    data_titles = []

    event_record.data_dictionary.each do |dd|
      q = "max( decode( d.title, '#{dd.title}', #{dd.data_type.storage})) #{dd.title}"
      data_titles << dd.title unless data_titles.include? dd.title
      data_query << q unless data_query.include? q
    end

    query = "
      select
        '#{event_name}' event_name,
        max( decode(e.name, '#{event_name}', realtime)) realtime,
        max( decode(e.name, '#{event_name}', labtime_decimal(e.labtime_hour, e.labtime_min, e.labtime_sec))) labtime,
        max( decode(e.name, '#{event_name}', e.labtime_year)) year
        #{(", " + data_query.join(",\n")) unless data_query.empty?}
      from events e
      left join data d on d.event_id = e.id
      left join data_values dv on d.id = dv.datum_id
      where e.subject_id = #{subject.id}
      and e.name = '#{event_name}'
      group by e.subject_id, e.id
    "


    if options[:use_materialized_view]
      materialized_view_name = "mv_#{subject.subject_code}_#{event_name}".upcase
      MY_LOG.info "Using View! #{materialized_view_name}"

      if options[:recreate]
        Event.connection.execute "drop materialized view #{materialized_view_name}", "SQL"
      end

      if options[:refresh]
        Event.connection.execute "BEGIN DBMS_SNAPSHOT.REFRESH( '#{materialized_view_name}','F'); end"
      end

      if Event.connection.exec_query("select mview_name from all_mviews where mview_name = '#{materialized_view_name}'").count == 0
        MY_LOG.info "Creating View! #{materialized_view_name}"
        ddl = "
          create materialized view #{materialized_view_name}
          using index
          refresh on demand complete
          disable query rewrite
          as
          #{query}
        "
        Event.connection.execute(ddl, "SQL")
      end

      res = Event.connection.exec_query("select event_name, realtime, labtime, year, #{data_titles.join(", ")} from #{materialized_view_name} order by labtime")

    else
      query += "order by labtime"
      res = Event.connection.exec_query query
    end

    res.map{|x|
      row_info = {
          realtime: (x["realtime"].getlocal.strftime('%FT%H:%M:%S') if x["realtime"]),
          labtime: x["labtime"],
          year: x["year"],
      }

      data_titles.each do |t|
        row_info[t] = x[t]
      end
      row_info
    }
  end

  def self.interval_list(subject, start_event_record, end_event_record)
    # subject_code, interval_name, labtime, labtime_year, realtime, [data for start event], [data for end event]

    start_event_name = start_event_record.name
    end_event_name = end_event_record.name

    event_dictionaries = {start: start_event_record, end: end_event_record}

    data_query = []
    data_titles = []
    event_dictionaries.values.each do |ed|
      ed.data_dictionary.each do |dd|
        q = "max( decode( d.title, '#{dd.title}', #{dd.data_type.storage})) #{dd.title}"
        data_titles << dd.title unless data_titles.include? dd.title
        data_query << q unless data_query.include? q
      end
    end

    query = "
      select
        max( decode(e.name, '#{start_event_name}', realtime)) start_realtime,
        max( decode(e.name, '#{end_event_name}', realtime)) end_realtime,
        max( decode(e.name, '#{start_event_name}', labtime_decimal(e.labtime_hour, e.labtime_min, e.labtime_sec))) start_labtime,
        max( decode(e.name, '#{end_event_name}', labtime_decimal(e.labtime_hour, e.labtime_min, e.labtime_sec))) end_labtime,
        max( decode(e.name, '#{start_event_name}', e.labtime_year)) start_year,
        max( decode(e.name, '#{end_event_name}', e.labtime_year)) end_year
        #{(", " + data_query.join(",\n")) unless data_query.empty?}
      from events e
      left join data d on d.event_id = e.id
      left join data_values dv on d.id = dv.datum_id
      where e.subject_id = #{subject.id}
      and (
        e.name = '#{start_event_name}' or
        e.name = '#{end_event_name}'
      )
      group by e.subject_id, e.group_label
      having count(e.group_label) > 1
    "

    #MY_LOG.info "VERY IMPORTANTAAKLDFJLKJ!!!!\n\n#{query}\n\n"

    res = Event.connection.exec_query query
    res.map{|x|
      row_info = {
          start_realtime: (x["start_realtime"].getlocal.strftime('%FT%H:%M:%S') if x["start_realtime"]),
          end_realtime: (x["end_realtime"].getlocal.strftime('%FT%H:%M:%S') if x["end_realtime"]),
          start_labtime: x["start_labtime"],
          end_labtime: x["end_labtime"],
          start_year: x["start_year"],
          end_year: x["end_year"]
      }

      data_titles.each do |t|
        row_info[t] = x[t]
      end
      row_info
    }
  end

  def self.direct_create(params)
    ## Differences between normal params and those used for this function:
    ##  event_dictionary (maybe move to outside?) exists in direct create, but not allowed attr normally
    ##  group_label seems to be missing from direct create
    ##  labtime is more flexible: can be sent as decimal or normal.
    ##  quality_flag_id not in accessible attributes yet

    ## :source_id, :subject_id, :labtime, :data_list

    ##

    #MY_LOG.info "dc params: #{params}"

    ## Validate
    [:subject_id, :source_id, :documentation_id, :name, :event_dictionary].each do |param_key|
      raise StandardError, "Missing parameter: #{param_key.to_s} || #{params}" if params[param_key].nil?
    end


    if params[:realtime].present? and params[:labtime].present?
      raise StandardError, "Both labtime and realtime present but do not match." unless params[:realtime] == params[:labtime].to_time
    elsif params[:realtime].present?
      params[:labtime] = Labtime.parse(params[:realtime])
    elsif params[:labtime].present?
      params[:realtime] = params[:labtime].to_time
    else
      raise StandardError, "Cannot create event - neither labtime nor realtime supplied."
    end

    if params[:event_dictionary].data_dictionary.present?
      raise StandardError, "Missing parameter: data_list || #{params}" if params[:data_list].nil?
      unless params[:data_list][:list].map{|dl| dl[:title]}.sort == params[:event_dictionary].data_dictionary.map { |dd| dd.title }.sort
        raise StandardError, "Cannot create event - data values do not match definitions: \nvals:#{params[:data_list][:list].map{|dl| dl[:title]}.sort}\ndefs: #{params[:event_dictionary].data_dictionary.map { |dd| dd.title }.sort}"
      end
    end


    ## Setup Variables
    current_time = Time.zone.now
    conn = self.connection
    ed = params[:event_dictionary]
    event_id = conn.next_sequence_value(self.sequence_name)

    ## Set Values for columns
    event_vals = {
        id: event_id,
        name: params[:name],
        subject_id: params[:subject_id],
        source_id: params[:source_id],
        documentation_id: params[:documentation_id],
        quality_flag_id: params[:quality_flag_id],
        realtime: params[:realtime],
        labtime_hour: params[:labtime].hour,
        labtime_min: params[:labtime].min,
        labtime_sec: params[:labtime].sec,
        labtime_year: params[:labtime].year,
        labtime_timezone: params[:labtime].time_zone.name,
        created_at: current_time,
        updated_at: current_time,
        notes: params[:notes],
        group_label: params[:group_label],
        deleted: 0
    }
    #MY_LOG.info "EV: #{event_vals}"
    event_binds = self.columns.map {|column| [column, event_vals[column.name.to_sym]]}
    conn.exec_insert "insert into events (#{self.column_names.join(", ")}) values (:#{self.column_names.join(", :")})", "SQL", event_binds

    ed.data_dictionary.each do |dd|
      #LOAD_LOG.info params[:data_list]
      type = dd.data_type.storage.to_sym
      selected_datums = params[:data_list][:list].select{|dv| dv[:title] == dd.title}
      raise StandardError, "Only one value of given title can be provided." unless selected_datums.length < 2

      val = selected_datums.first[:value]
      datum_id = conn.next_sequence_value(Datum.sequence_name)
      data_value_id = conn.next_sequence_value(DataValue.sequence_name)

      d = { id: datum_id, title: dd.title, created_at: current_time, updated_at: current_time, event_id: event_id, deleted: 0 }
      dv = {id: data_value_id, type_flag: type, created_at: current_time, updated_at: current_time, datum_id: datum_id, deleted: 0 }

      # Time value fix - roo does not convert into correct data type
      if type == :time_value
        if  val.class == Fixnum
          t = Time.at(val).getutc
          val = Time.zone.local(1, 1, 1, t.hour, t.min, t.sec)
        elsif val.class == Float
          val = nil
        end
      end

      dv[type] = val

      datum_binds = Datum.columns.map {|column| [column, d[column.name.to_sym]]}
      data_value_binds = DataValue.columns.map {|column| [column, dv[column.name.to_sym]]}

      #MY_LOG.info "S: #{params[:subject_id]} type: #{type} val: #{val} | #{val.class}\nD: #{d} \nDV: #{dv}\n\n\n"
      #MY_LOG.info data_value_binds

      conn.exec_insert "insert into data (#{Datum.column_names.join(", ")}) values (:#{Datum.column_names.join(", :")})", "SQL", datum_binds
      conn.exec_insert "insert into data_values (#{DataValue.column_names.join(", ")}) values (:#{DataValue.column_names.join(", :")})", "SQL", data_value_binds
    end

    true
  end

  def self.hard_delete(subject, name)
    conn = Event.connection
    conn.exec_delete "delete from events where name = '#{name}' and subject_id = #{subject.id}", "SQL", []
  end

  ##
  # Instance Methods

  def event_dictionary=(ed)
    self[:name] = ed.name
  end

  def event_dictionary
    EventDictionary.find_by_name(name)
  end

  def labtime
    if labtime_year.nil? or labtime_hour.nil? or labtime_min.nil? or labtime_sec.nil? or labtime_timezone.nil?
      nil
    else
      Labtime.new(labtime_year, labtime_hour, labtime_min, labtime_sec, ActiveSupport::TimeZone.new(labtime_timezone))
    end
  end

  def labtime=(value)
    if value.present?
      self[:labtime_year] = value.year
      self[:labtime_hour] = value.hour
      self[:labtime_min] = value.min
      self[:labtime_sec] = value.sec
      self[:labtime_timezone] = value.time_zone.name
      update_realtime
    end
  end

  def realtime=(value)
    if value.present?
      self[:realtime] = value.round(0)
      update_labtime
    end
  end

  # WHY WERE THESE TWO MADE INSTEAD OF OVERRIDING SETTERS?
  def labtime_update=(value)
    self.labtime = value
    update_realtime
  end

  def realtime_update=(value)
    self.realtime = value
    update_labtime
  end

  def data_list=(data_hash)
    # Example data list: {clear_all: false, list: [{title: dd.title, value: values[i], notes: "something"}]}
    #MY_LOG.info "KEYS: #{data_hash.keys}"
    raise ArguementError, "Data hash invalid. Must contain <clear_all> and <list> keys." unless (data_hash.keys && [:clear_all, :list]).length == 2

    should_clear = data_hash[:clear_all].to_i == 1

    if should_clear
      #MY_LOG.info "CLEAR ALL"
      data.clear
    end

    data_hash[:list].each do |params|
      if record_has_datum(params[:title])
        current_data = data.select{|d| d.title == params[:title]}
        if current_data.length > 1
          raise StandardError, "Failed to add/update Datum. Cannot have more than one associated datum with same title."
        elsif current_data.length == 1
          current_data.first.logged_update(params)
        else
          datum = Datum.new(params)
          datum.event = self
          data << datum
        end
      end
    end

  end

  def datum(title)
    #MY_LOG.info data.to_a
    return nil unless event_dictionary and event_dictionary.data_dictionary # TODO:  maybe get rid of this?
    if record_has_datum(title)
      data.select{|d| d.title == title.to_s}.first
    end
  end

  private

  def record_has_datum(title)
    return nil unless event_dictionary and event_dictionary.data_dictionary # TODO:  maybe get rid of this?
    event_dictionary.data_dictionary.find_by_title(title).nil? ? false : true
  end

  def synchronize_times
    conv_labtime = Labtime.parse(realtime)
    conv_realtime = labtime.nil? ? nil : labtime.to_time

    if realtime.present? and labtime.present? and (conv_labtime != labtime or conv_realtime != realtime)
      raise StandardError, "#{(conv_realtime != realtime)}Error: labtime and realtime both set but do not match. labtime: #{labtime.to_s} realtime: #{realtime} #{conv_realtime}"
    end

    self.realtime = conv_realtime if realtime.nil? and not conv_realtime.nil?
    self.labtime = conv_labtime if labtime.nil? and not conv_labtime.nil?

    self.realtime_offset_sec = realtime.utc_offset if realtime.present?
  end

  def update_realtime
    self[:realtime] = labtime.to_time
  end

  def update_labtime
    self.labtime = Labtime.parse(realtime)
  end

  # Custom Validations
  def name_has_to_be_defined_in_dictionary
    unless EventDictionary.find_by_name(name)
      errors.add(:name, "has to be defined in Event Dictionary.")
    end
  end

  def time_must_be_defined
    if realtime.blank? and labtime.blank?
      errors.add(:realtime, "has to be defined if labtime is not defined.")
      errors.add(:labtime, "has to be defined if realtime is not defined.")
    end
  end
end
