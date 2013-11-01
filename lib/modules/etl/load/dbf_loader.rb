module ETL
=begin

  NewForms MAP

  pair
  005: In Bed ==> in_bed_scheduled
  005: Out of Bed ==> out_of_bed_scheduled
  022: Sleep Episode (start) ==> sleep_start_scheduled, lighting_change_scheduled (sleep_start has episode_number)
  023: Wake Time (start) ==> wake_start_scheduled, lighting_change_scheduled (wake_start has episode_number)
  024: Lighting Change (start) ==> lighting_change_scheduled
  OTHERS:
      new_forms_event
  - event_code
  - event_description


  ### RESTRICTIONS!
  - Has to have subject supplied
  - Can only make events as part of object list
  - either add to previous events or delete all
  - What varies between different types of events?
    - what captures are used for
    - what event name is used
    - what data list is made

  ### SAMPLE CONFIG PARAMS

    {
        conditional_columns: [2, 3], # empty if same treatment!
        static_params: {labtime_year: 2012}, # in addition, source_id, documentation_id, and subject_id are set automatically
        conditions: {# Must be of same length as columns array
                     [/In Bed/, /005/] => {
                         event_map: [
                             # existing_records - :destroy or :ignore
                             # name - event name
                             {name: :in_bed_scheduled, existing_records: :destroy, labtime_fn: :from_s}
                         ],

                         event_groups: [[:event_name_1, :event_name_2],[:event_name_3, :event_name_4]], # Will give same group id to these event pairs when 2nd one follows the first.

                         column_map: [
                             # target - :event or :datum or :subject_code_verification or :none
                             # name - event name. When NO NAME, APPLIES TO ALL EVENTS
                             # field - event field name or datum title
                             {target: :event, name: :in_bed_scheduled, field: :labtime},
                             {target: :event, name: :in_bed_scheduled},
                             {target: :none},
                             {target: :none},
                             {target: :subject_code_verification}
                         ],
                         capture_map: [
                             # array length must == number of captures in given pattern
                             # target: :event or :datum or :subject_code_verification or :none
                             # field - event field name or datum title
                             # name - event name
                         ]
                     },
                     [/Out of Bed/, /005/] => {
                         event_map: [{name: :out_of_bed_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                         column_map: [{target: :event, field: :labtime}, {target: :event}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                         capture_map: []
                     },
                     [/Lighting Change Lux=(\d+)/, /024/] => {
                         event_map: [{name: :lighting_change_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                         column_map: [{target: :event, field: :labtime}, {target: :event}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                         capture_map: [{target: :datum, name: :lighting_change_scheduled, field: :light_level}]
                     },
                     [/Sleep Episode #(\d+) Lux=(\d+)/, /022/] => {
                         event_map: [{name: :lighting_change_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :sleep_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                         column_map: [{target: :event, field: :labtime}, {target: :event}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                         capture_map: [
                             {target: :datum, name: :sleep_start_scheduled, field: :episode_number},
                             {target: :datum, name: :lighting_change_scheduled, field: :light_level}
                         ]
                     },
                     [/Wake Time #(\d+) Lux=(\d+)/, /023/] => {
                         event_map: [{name: :lighting_change_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :wake_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                         column_map: [{target: :event, field: :labtime}, {target: :event}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                         capture_map: [
                             {target: :datum, name: :wake_start_scheduled, field: :episode_number},
                             {target: :datum, name: :lighting_change_scheduled, field: :light_level}
                         ]
                     },
                     [] => {# Default! Also, when columns empty, only allowed one
                            event_map: [{name: :new_forms_event, existing_records: :destroy, labtime_fn: :from_s}],
                            column_map: [{target: :event, field: :labtime}, {target: :event}, {target: :datum, field: :event_description}, {target: :datum, field: :event_code}, {target: :subject_code_verification}],
                            capture_map: []
                     }
        },
    }
=end


  class DbfLoader
    def initialize(dbf_path, config_params, source, documentation, subject)

      case File.extname(dbf_path).downcase
        when '.csv'
          @dbf_file = Roo::CSV.new(dbf_path, {file_warning: :ignore})
          @first_row = 1
        when '.dbf'
          @first_row = 2
          @dbf_file = ETL::DbfReader.open(dbf_path)
        else
          raise StandardError, "Cant recognize file name!"
      end

      raise StandardError, "File not opened: #{@dbf_file.filename}" unless File.readable?(@dbf_file.filename)

      @config = Hash(config_params)

      @subject = subject
      @source = source
      @documentation = documentation


      find_event_dictionaries
      set_labtime_functions
      parse_existing_records
      set_up_group_map(@config[:event_groups])

    end

    def load
      begin
        raise StandardError, "Subject not found: #{@subject.subject_code}" unless @subject
        raise StandardError, "Subject has no admit date: #{@subject.subject_code}" unless @subject.admit_date.present?

        # Build static params
        static_params = build_static_params

        Event.transaction do
          deal_with_existing_records
          (@first_row..@dbf_file.last_row).each do |i|
            row = @dbf_file.row(i)

            # Select Mapping
            row_mapping = select_row_mapping(row)

            # Initialize event attrs
            events_attrs = {}
            row_mapping[:event_map].each do |event_hash|
              eh = {name: event_hash[:name], event_dictionary: @event_dictionaries[event_hash[:name]], labtime_year: @subject.admit_date.year}
              events_attrs[event_hash[:name]] = eh.merge static_params
            end

            # Add column values
            row_mapping[:column_map].each_with_index do |col_params, i|
              val = row[i]

              add_to_event_attrs(events_attrs, col_params, val)
            end

            # Add matched values
            row_mapping[:capture_map].each_with_index do |capture_params, i|
              val = row_mapping[:captures][i]

              add_to_event_attrs(events_attrs, capture_params, val)
            end

            # Add group ids
            add_group_labels(events_attrs)

            # Clean labtime params
            set_labtime_param(events_attrs)

            # Create Events
            events_attrs.values.each do |event_attrs|
              Event.direct_create(event_attrs)
            end
          end
        end

        @dbf_file.close if @dbf_file.respond_to? :close
      rescue Exception => e
        LOAD_LOG.error "\n#############!!!!!\nFailed to load events for subject #{@subject.subject_code}!\n#{e.message}\n#{e.backtrace.inspect}#############!!!!!\n\n"
        MY_LOG.error "\n#############!!!!!\nFailed to load events for subject #{@subject.subject_code}!\n#{e.message}\n#{e.backtrace.inspect}#############!!!!!\n\n"
      end
    end

    private


    def add_to_event_attrs(event_attrs, params, value)
      case params[:target]
        when :event
          add_event_field(event_attrs, params[:field], value , params[:name])
        when :datum
          add_datum(event_attrs, params[:field], value, params[:name])
        when :subject_code_verification
          verify_subject(value)
        else
          nil
      end
    end

    def verify_subject(subject_code)
      if subject_code.present? and subject_code.upcase != @subject.subject_code.upcase
        raise StandardError, "Subject from file does not match supplied subject. file subject code: #{subject_code} supplied subject code: #{@subject.subject_code}"
      end
    end


    def add_event_field(event_attrs, field_name, value , event_name)
      if event_name
        event_attrs[event_name][field_name] = value
      else
        event_attrs.keys.each { |key| event_attrs[key][field_name] = value }
      end
    end

    def add_datum(event_attrs, title, value, event_name)
      dl_template = {clear_all: 0, list: []}
      if event_name
        event_attrs[event_name][:data_list] ||= dl_template
        event_attrs[event_name][:data_list][:list] << {title: title.to_s, value: value}
      else
        event_attrs.keys.each do |key|
          event_attrs[key][:data_list] ||= dl_template
          event_attrs[key][:data_list][:list] << {title: title.to_s, value: value}
        end
      end
    end


    def build_static_params
      static_params = @config[:static_params]
      static_params[:source_id] = @source.id
      static_params[:documentation_id] = @documentation.id
      static_params[:subject_id] = @subject.id

      static_params
    end

    def select_row_mapping(row)
      conditional_values = @config[:conditional_columns].map {|index| row[index]}
      row_mapping = nil

      @config[:conditions].each do |field_patterns, mapping|
        match = true
        captures = []
        field_patterns.each_with_index do |pattern, i|
          match_result = pattern.match conditional_values[i]
          if match_result
            captures += match_result.captures
          else
            match = false
            break
          end
        end

        if match
          row_mapping = mapping.clone
          row_mapping[:captures] = captures
          break
        end
      end

      row_mapping
    end

    def find_event_dictionaries
      @event_dictionaries = {}

      event_list = @config[:conditions].values.map {|mapping| mapping[:event_map].map {|event_info| event_info[:name] } }.flatten.uniq

      event_list.each do |name|
        ed = EventDictionary.find_by_name(name)
        raise StandardError, EventDictionary.all.map(&:name) unless ed
        @event_dictionaries[name.to_sym] = ed
      end
    end

    def set_labtime_functions
      @labtime_function = {}

      event_list = @config[:conditions].values.map {|mapping| mapping[:event_map].map {|event_info| { name: event_info[:name], labtime_fn: event_info[:labtime_fn] } } }.flatten.uniq

      event_list.each do |x|
        @labtime_function[x[:name]] = x[:labtime_fn]
      end
    end

    def set_labtime_param(events_attrs)
      events_attrs.keys.each do |name|
        labtime_function = @labtime_function[name]

        labtime = events_attrs[name].delete(:labtime)


        if labtime.present? and labtime_function == :from_s
          events_attrs[name][:labtime] = Labtime.from_s(labtime, {year: events_attrs[name].delete(:labtime_year), hour: events_attrs[name].delete(:labtime_hour), min: events_attrs[name].delete(:labtime_min), sec: events_attrs[name].delete(:labtime_sec)})
        else
          raise StandardError, "fns: #{@labtime_function}\nlabtime: #{labtime}\nlabtime_fn: #{labtime_function}\natt: #{events_attrs[name]}"
        end

      end
    end


    def parse_existing_records
      @existing_record_actions = {}

      event_list = @config[:conditions].values.map {|mapping| mapping[:event_map].map {|event_info| { name: event_info[:name], action: event_info[:existing_records] } } }.flatten.uniq

      event_list.each do |x|
        @existing_record_actions[x[:name]] = x[:action]
      end

    end

    def deal_with_existing_records
      @existing_record_actions.each do |name, action|
        if action == :destroy
          Event.hard_delete(@subject, name)
        end
      end
    end

    def set_up_group_map(groups)
      @group_map = {mapping: {}}

      raise StandardError, "All group entries must be unique!" unless groups.flatten.uniq.length == groups.flatten.length

      groups.each do |group|
        # first group element
        @group_map[:mapping][group[0]] = { type: :start, partner: group[1] }
        @group_map[:mapping][group[1]] = { type: :end, current_group_label: nil, partner: group[0] }
      end

      @group_map[:start_points] = @group_map[:mapping].select {|k, v| v[:type] == :start}.keys
      @group_map[:end_points] = @group_map[:mapping].select {|k, v| v[:type] == :end}.keys




    end

    def add_group_labels(events_attrs)

      # we have a grouping map.
      # any time an event is being created which is a first event in a pair, set group id for that pair.
      # any time an event is being created which is 2nd in a pair, set its group id from setting and close pair. NO NESTING!!!!!?????
      # FOR NOW, ASSUMES NO NESTING - linear!!!
      # SO, WHAT HAPPENS IF 1ST PAIR COMES IN BEFORE 2nd PAIR SEEN???? THIS CAN HAPPEN IF THE SAME PAIR IS DEFINED FOR THE SAME ROW!!! LIKE LIGHTING
      # LETS ALLOW FOR A SINGLE ONE TO WORK
      # END HAS TO BE BEFORE START!!!!

      # Do ENDS FIRST!!!
      (@group_map[:end_points] & events_attrs.keys).each do |event_name|
        this_mapping = @group_map[:mapping][event_name]
        if this_mapping[:current_group_label].present?
          events_attrs[event_name][:group_label] = this_mapping[:current_group_label]
          this_mapping[:current_group_label] = nil
          @group_map[:mapping][this_mapping[:partner]][:current_group_label] = nil
        else
          events_attrs[event_name][:group_label] = ActiveRecord::Base.connection.next_sequence_value "object_id_seq"
          error =  "Unmatched End Event! #{events_attrs[event_name]}"
          MY_LOG.error error
          LOAD_LOG.error error
        end
      end

      # Once ends are closed, Do any starts
      (@group_map[:start_points] & events_attrs.keys).each do |event_name|
        this_mapping = @group_map[:mapping][event_name]

        if this_mapping[:current_group_label].present?
          error = "Unmatched Start Event! #{events_attrs[event_name]}"
          MY_LOG.error error
          LOAD_LOG.error error
        end

        new_group_label = ActiveRecord::Base.connection.next_sequence_value "object_id_seq"
        events_attrs[event_name][:group_label] = new_group_label
        this_mapping[:current_group_label] = new_group_label
        @group_map[:mapping][this_mapping[:partner]][:current_group_label] = new_group_label
      end





    end
  end
end