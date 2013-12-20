class Subject < ActiveRecord::Base
  ##
  # Associations
  has_many :principal_investigators, :class_name => "Researcher", :through => :subjects_pis, :source => :researcher
  has_many :subjects_pis
  has_many :project_leaders, :class_name => "Researcher", :through => :subjects_project_leaders, :source => :researcher
  has_many :subjects_project_leaders
  has_many :irbs, :through => :subjects_irbs
  has_many :subjects_irbs
  has_many :publications, :through => :subjects_publications
  has_many :subjects_publications
  has_many :events, :autosave => true
  has_many :subject_groups, :through => :subjects_subject_groups#, :conditions => "name != 'authorized'"
  has_many :subjects_subject_groups
  belongs_to :study

  ##
  # Attributes
  # attr_accessible :admit_date, :discharge_date, :disempanelled, :notes, :study_id, :subject_code, :t_drive_location, :pl_list, :pi_list, :subject_group_ids

  ##
  # Callbacks

  ##
  # Concerns
  include Loggable, Associatable, Indexable, Deletable

  ##
  # Database Settings

  ##
  # Pattern
  SUBJECT_CODE_REGEX = /(\d[0-9a-z]*[a-z][0-9a-z]*)/

  ##
  # Scopes
  # scope :current, conditions: { deleted: false }
        #joins(:subjects_subject_groups).where("subjects.deleted = ? and subjects_subject_groups.subject_group_id = ?", false, 50565930)#
  ## Search By
  # study
  # irb
  # researcher
  # subject group
  scope :search, lambda { |term| search_scope([:subject_code, :notes, {join: :subject_groups, column: :name }, {join: :study, column: :official_name }, {join: :irbs, column: :title }], term) }
  scope :in_subject_group, lambda { |subject_groups| joins(:subject_groups).where(subject_groups: {name: subject_groups}) }


  ##
  # Validations
  validates_presence_of :subject_code
  validates_uniqueness_of :subject_code

  ##
  # Class Methods

  ##
  # Instance Methods
  #
  def event_types
    Event.select(:name).where(subject_id: id).uniq.map(&:name)

  end

  #def raster_data
  #
  #  conn = self.connection
  #
  #  light_levels = conn.exec_query("
  #    select * from (
  #    select
  #    max( decode(name, 'lighting_block_start_scheduled', realtime)) realtime,
  #    max( dv.num_value ) light_level
  #    from events e
  #    left join data d on d.event_id = e.id
  #    left join data_values dv on d.id = dv.datum_id
  #    where e.subject_id = #{self.id}
  #    and (
  #    e.name = 'lighting_block_start_scheduled' or
  #        e.name = 'lighting_block_end_scheduled'
  #    )
  #    group by group_label
  #    having count(e.id) = 2
  #    )
  #    union
  #    (
  #    select
  #    max( decode(name, 'lighting_block_end_scheduled', realtime)) realtime,
  #    max( dv.num_value ) light_level
  #    from events e
  #    left join data d on d.event_id = e.id
  #    left join data_values dv on d.id = dv.datum_id
  #    where e.subject_id = #{self.id}
  #    and (
  #    e.name = 'lighting_block_start_scheduled' or
  #        e.name = 'lighting_block_end_scheduled'
  #    )
  #    group by group_label
  #    having count(e.id) = 2)
  #  ").map{|x| [x["realtime"].getlocal.strftime('%FT%T'), x["light_level"]] }
  #
  #  sleep_blocks = conn.exec_query("
  #    select
  #      max( decode(name, 'in_bed_start_scheduled', realtime)) start_time,
  #      max( decode(name, 'in_bed_end_scheduled', realtime)) end_time
  #    from
  #      events
  #    where subject_id = #{self.id}
  #    and (name = 'in_bed_start_scheduled' or name = 'in_bed_end_scheduled')
  #    group by group_label
  #    having count(id) = 2
  #  ").map{|x| [x["start_time"].getlocal.strftime('%FT%T'), x["end_time"].getlocal.strftime('%FT%T')]}
  #
  #  config = {
  #      title: self.subject_code,
  #      save_path: File.join(Rails.root, "app/assets/images/rasters"),
  #      filename: "#{subject_code}.png",
  #      block_events: [
  #          name: "Sleep",
  #          color: "black",
  #          class: "start_end",
  #          group: 1,
  #          height: 5,
  #          times: sleep_blocks
  #      ]
  #  }
  #
  #  File.open("app/assets/images/rasters/#{subject_code}.json", "w") do |f|
  #    f.write(config.to_json)
  #  end
  #
  #
  #  config
  #end
  #
  #def draw_raster
  #  raster_data
  #
  #end
  #


  # {:subject_id=>1141749, :subject_code=>"26N2GXT2", :block_name=>"scored_epoch", :realtime=>nil, :labtime=>#<BigDecimal:992b450,'0.6981476666 6666666666 6666666666 666666667E4',45(54)>, :year=>2006, "epoch_length"=>30, "sleep_wake_period"=>1, "scored_stage"=>2}

  def destroy
    update_column :deleted, true
  end

  def irb_list=(irb_hash)
    set_list(SubjectsIrb, Irb, irb_hash)
  end

  def publication_list=(publication_hash)
    set_list(SubjectsPublication, Publication, publication_hash)
  end

  def pi_list=(pi_hash)
    set_list(SubjectsPi, Researcher, pi_hash)
  end

  def pl_list=(project_leader_hash)
    set_list(SubjectsProjectLeader, Researcher, project_leader_hash)
  end

  def project_leader(role)
    spl = SubjectsProjectLeader.find_by_subject_id_and_role(self.id, role)
    spl.researcher
  end


  ## RASTER-SPECIFIC
  # TODO: REFACTOR

  def main_raster(json, timescale = :labtime)
    json.title subject_code
    json.save_path "/home/pwm4/Desktop/rasters" #File.join(Rails.root, "app", "assets", "images", "rasters")
    json.filename "#{subject_code}.pdf"
    json.t_cyle 24
    json.timescale timescale.to_s
    json.day_height 0.5

    json.events do
      json.child! do
        json.name "light_episode"
        json.type "block"
        json.position 0
        json.height 1
        json.blocks do
          json.array! light_episodes(timescale)
        end
      end
      json.child! do
        json.name "sleep_episode"
        json.type "block"
        json.position -0.5
        json.height 0.5
        json.color "#000000"
        json.blocks do
          json.array! sleep_episodes(timescale)
        end
      end
    end
  end

  def scored_sleep_raster(json, timescale = :labtime)
    json.title subject_code
    json.save_path File.join(Rails.root, "app", "assets", "images", "rasters")
    json.filename "#{subject_code}.png"
    json.t_cyle 24
    json.timescale timescale.to_s
    json.day_height 0.5

    json.events do
      json.child! do
        json.name "light_episode"
        json.type "block"
        json.position 0
        json.height 1
        json.blocks do
          json.array! light_episodes(timescale)
        end
      end
      json.child! do
        json.name "sleep_episode"
        json.type "block"
        json.position -1
        json.height 1
        json.color "#000000"
        json.blocks do
          json.array! sleep_episodes(timescale)
        end
      end
      json.child! do
        json.name "stage"
        json.type "linear"
        json.color "#000000"
        json.limits [1, 6]
        json.points do
          json.array! scored_epochs(timescale)
        end

      end
    end
  end

  def json_rep
    Jbuilder.encode do |json|
      main_raster(json, :realtime)
    end
  end

  

  def light_episodes(timescale = :labtime)
    eds = {start: EventDictionary.find_by_name("light_episode_start"), end: EventDictionary.find_by_name("light_episode_end")}

    res = Event.interval_list self, eds[:start], eds[:end]


    #{
    #    name: "light_episode",
    #    blocks: res.map do |row|
    #      [
    #          row[:start_labtime],
    #          row[:end_labtime],
    #          convert_brightness(row["light_level"])
    #      ]
    #    end
    #
    #}
    res.map do |row|
      select_timescale(row, timescale).append(convert_brightness(row["light_level"]))#.append(row["light_level"])
    end
  end

  def sleep_episodes(timescale = :labtime)
    eds = {start: EventDictionary.find_by_name("sleep_period_start"), end: EventDictionary.find_by_name("sleep_period_end")}

    res = Event.interval_list self, eds[:start], eds[:end]

    res.map do |row|
      select_timescale(row, timescale)
    end
  end

  def scored_epochs(timescale = :labtime, period = false, subject_code=false, epoch_length=false)
    ed = EventDictionary.find_by_name("scored_epoch")

    res = Event.continuous_list self, ed

    ep = res[0]["epoch_length"]

    ret = res.map do |row|
      res = []
      res << self[:subject_code] if subject_code
      res << row["sleep_wake_period"] if period
      res << row[timescale]
      res << row["scored_stage"]
      res
    end

    if epoch_length
      { epoch_length: ep, data: ret }
    else
      ret
    end
  end

  def get_bouts(type, length, next_state_type)
    d = scored_epochs(:labtime, true, true, true)
    epoch_length = d[:epoch_length] / 60.0

    bm = Tools::BoutMaker.new(d[:data], length, epoch_length, next_state_type)

    if type == :all
      bm.all_bouts
    else
      bm.send("#{type}_bouts")
    end

  end

  def draw_raster(type)
    data = Jbuilder.encode do |json|
      main_raster(json, :realtime)
    end
    r = RSRuby.instance
    r.library("dsm.raster.plot")
    r.plot_raster(data)
  end

  def admit_date
    Date.new(admit_year, admit_month, admit_day)
  end

  def admit_date=(date)
    self[:admit_year] = date.year
    self[:admit_month] = date.month
    self[:admit_day] = date.day
  end

  def discharge_date
    Date.new(discharge_year, discharge_month, discharge_day)
  end

  def discharge_date=(date)
    self[:discharge_year] = date.year
    self[:discharge_month] = date.month
    self[:discharge_day] = date.day
  end

  private

  def select_timescale(row, timescale)
    if timescale == :labtime
      [row[:start_labtime], row[:start_year], row[:end_labtime], row[:end_year]]
    elsif timescale == :realtime
      [row[:start_realtime], row[:end_realtime]]
    end
  end

  def convert_brightness(lux_val)
    # Converts from lux value (range 0 - 10000) to hex color (bw)
    if lux_val
      hex_s = [Math.log(lux_val + 1, 1.0368).ceil, 255].min.to_s(16)
      hex_s = (hex_s.length > 1 ? hex_s * 2 : ("0"+hex_s) * 2) + "00"
      hex_s = "#" + hex_s + "BB"
      hex_s
    end
  end


end
