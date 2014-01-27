class EventDictionary < ActiveRecord::Base
  ##
  # Associations
  has_many :event_tags, :through => :event_dictionary_event_tags
  has_many :event_dictionary_event_tags
  has_many :data_dictionary, :through => :event_dictionary_data_fields
  has_many :event_dictionary_data_fields
  has_many :events, :foreign_key => :name, :primary_key => :name
  belongs_to :paired_event_dictionary_i, class_name: "EventDictionary", foreign_key: "paired_id"
  has_one :paired_event_dictionary, class_name: "EventDictionary", foreign_key: "paired_id", autosave: true

  ##
  # Attributes
  #attr_accessible :description, :name, :data_dictionary_ids, :event_tag_ids

  ##
  # Callbacks

  ##
  # Concerns
  include Loggable, Indexable, Deletable

  ##
  # Database Settings

  ##
  # Scopes
  scope :search, lambda { |term| search_scope([:name, :description], term) }

  ##
  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name

  ##
  # Class Methods

  ##
  # Instance Methods

  def event_data_query_sql(attrs = {})
    paired = attrs[:ignore_paired] ? nil : paired_event_dictionary
    event_records = [self, paired].compact
    data_records = event_records.map(&:data_dictionary).flatten.uniq

    data_query = []
    data_titles = []

    query = "select s.id subject_id, s.subject_code subject_code"
    
    if event_records.length > 1
      event_records.each_with_index do |er, j|
        i = j + 1
        query += %(, max( decode(e.name, '#{er.name}', e.id)) #{i.en.ordinate}_event_id,
          max( decode(e.name, '#{er.name}', e.name)) #{i.en.ordinate}_event_name,
          max( decode(e.name, '#{er.name}', labtime_hour)) #{i.en.ordinate}_labtime_hour,
          max( decode(e.name, '#{er.name}', labtime_min)) #{i.en.ordinate}_labtime_min,
          max( decode(e.name, '#{er.name}', labtime_sec)) #{i.en.ordinate}_labtime_sec,
          max( decode(e.name, '#{er.name}', labtime_year)) #{i.en.ordinate}_labtime_year,
          max( decode(e.name, '#{er.name}', labtime_decimal(e.labtime_hour, e.labtime_min, e.labtime_sec))) #{i.en.ordinate}_decimal_labtime,
          max( decode(e.name, '#{er.name}', realtime)) #{i.en.ordinate}_realtime)
      end
    else
      query += ", e.id event_id, max(e.name) event_name, max(e.labtime_hour) labtime_hour, max(e.labtime_min) labtime_min, max(e.labtime_sec) labtime_sec, max(e.labtime_year) labtime_year, max(labtime_decimal(e.labtime_hour, e.labtime_min, e.labtime_sec)) decimal_labtime, max(e.realtime) realtime"
    end
    
    data_records.each do |dr|
      q = "max( decode( d.title, '#{dr.title}', #{dr.data_type.storage})) #{dr.title}"
      data_titles << dr.title unless data_titles.include? dr.title
      data_query << q unless data_query.include? q
    end

    unless data_query.empty?
      query += (", " + data_query.join(",\n"))
    end

    query += %(
      from events e
        join subjects s on s.id = e.subject_id
        left join data d on d.event_id = e.id
        left join data_values dv on d.id = dv.datum_id
        join subjects_subject_groups ssg on ssg.subject_id = s.id
        join subject_groups sg on sg.id = ssg.subject_group_id\n
    )

    query += %(where (#{event_records.map{|er| "e.name = '#{er.name}'"}.join(' or ')}))
    query += %( and sg.name = '#{attrs[:subject_group_name]}') if attrs[:subject_group_name]
    query += %( and s.subject_code = '#{attrs[:subject_code]}') if attrs[:subject_code]

    query += %(\n
      group by s.id, s.subject_code, #{event_records.length > 1 ? "e.group_label" : "e.id"}
      order by s.subject_code, #{"first_" if event_records.length > 1}decimal_labtime
    )

    query.strip.gsub(/\s+/, ' ')
  end

  private
end
