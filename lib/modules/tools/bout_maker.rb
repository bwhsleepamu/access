module Tools
  class BoutMaker
    def self.to_file(subject_code, type, epochs_per_bout, epoch_length, bouts, location, filename = nil)
      minimum_bout_length = (epochs_per_bout * epoch_length).round(2)

      filename = "#{subject_code}_#{type}_bouts_#{minimum_bout_length}.csv"
      file_path = File.join(location, filename)

      File.open(file_path, 'w') do |outfile|
        outfile.write("Minimum bout length #{minimum_bout_length} minutes\n")
        outfile.write("Subject, Sleep period, Bout start time, Bout duration, Censored, Next state\n")

        bouts.each do |row|
          row[2] = "%.3f" % row[2].round(3)
          row[3] = (row[3] % 1 == 0) ? row[3].to_i.to_s : "%.1f" % row[3]
          outfile.write row.to_csv({col_sep: ", "})
        end
      end

      file_path
    end

    def self.to_string(subject_code, type, epochs_per_bout, epoch_length, bouts)
      minimum_bout_length = (epochs_per_bout * epoch_length).round(2)

      s = "Minimum bout length #{minimum_bout_length} minutes\n"
      s += "Subject, Sleep period, Bout start time, Bout duration, Censored, Next state\n"

      bouts.each do |row|
        row[2] = "%.3f" % row[2].round(3)
        row[3] = (row[3] % 1 == 0) ? row[3].to_i.to_s : "%.1f" % row[3]
        s += row.to_csv({col_sep: ", "})
      end

      s
    end

    def self.from_file(filepath)
      CSV.read(filepath)
    end

    def initialize(input_data, min_length = 2, epoch_length = 0.5, next_state_type = :numeric)
      @epoch_data = input_data
      @min_bout_length = min_length
      @epoch_length = epoch_length
      @subject_code = input_data.first[0]
      @next_state_type = next_state_type
    end

    def all_bouts
      {sleep: sleep_bouts, wake: wake_bouts, rem: rem_bouts, nrem: nrem_bouts}
    end

    def sleep_bouts
      chunks = chunked_epochs(@epoch_data, false)
      generate_bouts(chunks, :sleep, [:undef, :lights_on], [:wake], [:sleep], false)
    end

    def wake_bouts
      chunks = chunked_epochs(@epoch_data, false)
      generate_bouts(chunks, :wake, [:undef, :lights_on], [:sleep], [:sleep], true)

    end

    def rem_bouts
      chunks = chunked_epochs(@epoch_data, true)
      generate_bouts(chunks, :rem, [:undef, :lights_on], [:nrem, :wake], [:nrem, :rem], true)

    end

    def nrem_bouts
      chunks = chunked_epochs(@epoch_data, true)
      generate_bouts(chunks, :nrem, [:undef, :lights_on], [:rem, :wake], [:nrem, :rem], true)
    end


    def subject_code
      @subject_code
    end
    private

    def generate_bouts(chunked_data, target, censor, no_censor, start_of_sleep_markers, differentiate_sleep)
      # data: the chunked epoch data to be analyzed
      # target: the label for the type of bout desired
      #
      # the target bout will be censored or not censored, depending on what type of bout follows
      #   censor: list of bouts for which the target bout will be censored
      #   no_censor: list of bouts for which the target bout will not be censored
      #
      # start_of_sleep_marker: list of the types of bouts that indicate sleep has started

      # Initialize
      cleaned_bouts = []

      chunked_data.each do |period, chunked_epochs|
        sleep_did_not_begin = true

        chunked_epochs.each do |chunk|
          #MY_LOG.info "#{chunk[0]} | #{chunk[1].first[2].to_f.round(3)} | #{chunk[1].length}"
          if sleep_did_not_begin
            # INIT with first bout
            if start_of_sleep_markers.include?(chunk[0]) and chunk[1].length >= @min_bout_length
              #MY_LOG.info "Initializing"
              sleep_did_not_begin = false
              cleaned_bouts << formatted_bout(chunk, period) if chunk[0] == target
            end
          elsif chunk[1].length < @min_bout_length and chunk[0] != :lights_on and cleaned_bouts.present? and last_bout_open?(cleaned_bouts)
            #MY_LOG.info "Merging small bout: #{chunk[1]}"
            # Merge in bouts < min length
            cleaned_bouts.last[:length] += chunk[1].length
          else
            case chunk[0]
              when *no_censor
                # End bout without censor
                #MY_LOG.info "no_censor"
                unless cleaned_bouts.empty? || last_bout_closed?(cleaned_bouts) or chunk_is_too_short?(chunk)
                  #MY_LOG.info "     and end bout!"
                  close_last_bout(cleaned_bouts, false, formatted_next_state(chunk[1].first[3].to_i, differentiate_sleep))
                end
              when *censor
                # End bout with censor
                #MY_LOG.info "censor"
                unless cleaned_bouts.empty? or last_bout_closed?(cleaned_bouts) or chunk_is_too_short?(chunk)
                  #MY_LOG.info "     and end bout!"
                  close_last_bout(cleaned_bouts, true)
                end
              when target

                #MY_LOG.info "target"
                if cleaned_bouts.present? and last_bout_open?(cleaned_bouts)
                  #MY_LOG.info "     and append last bout!"
                  cleaned_bouts.last[:length] += chunk[1].length
                elsif chunk[1].length >= @min_bout_length
                  #MY_LOG.info "     and add new bout!"
                  cleaned_bouts << formatted_bout(chunk, period)
                else
                  #MY_LOG.info "    and do nothing!"
                end
              else
                raise StandardError, "Undefined bout type: #{chunk[0]}"
            end
          end
        end

        if cleaned_bouts.present? and last_bout_open?(cleaned_bouts)
          close_last_bout(cleaned_bouts, true)
        end
      end


      #MY_LOG.info "\n\n"
      #MY_LOG.info cleaned_bouts

      cleaned_bouts.map {|bout| [@subject_code, bout[:period], bout[:start], bout[:length]*@epoch_length, bout[:censored], bout[:next_state]]}
    end

    def close_last_bout(cleaned_bouts, censored = true, next_state = ".")
      if censored
        cleaned_bouts.last[:censored] = 1
      else
        cleaned_bouts.last[:censored] = 0
      end

      cleaned_bouts.last[:next_state] = next_state
    end

    def last_bout_open?(cleaned_bouts)
      !last_bout_closed?(cleaned_bouts)
    end

    def last_bout_closed?(cleaned_bouts)
      (cleaned_bouts.last[:censored] && cleaned_bouts.last[:next_state])
    end

    def chunk_is_long_enough?(chunk)
      chunk[0] == :lights_on ? true : (chunk[1].length >= @min_bout_length)
    end

    def chunk_is_too_short?(chunk)
      !chunk_is_long_enough?(chunk)
    end

    def chunked_epochs(data, differentiate_sleep = false)
      chunked_by_period = data.chunk do |epoch|
        if epoch[1].to_i < 0
          nil
        else
          epoch[1].to_i
        end
      end
      chunked_by_period.map do |period, epochs|
        [period, chunk_period(epochs, differentiate_sleep)]
      end
    end

    def chunk_period(data, differentiate_sleep)
      data.chunk do |epoch|
        if epoch[1].to_i < 0
          nil
        else
          map_state(epoch[3].to_i, differentiate_sleep)
        end
      end
    end

    def formatted_bout(chunk, period)
      { type: chunk[0], period: period, start: chunk[1].first[2].to_f, length: chunk[1].length}#, can_merge: true }
    end

    def formatted_next_state(numeric_state, differentiate_sleep)
      if @next_state_type == :numeric
        numeric_state
      elsif @next_state_type == :category
        map_state(numeric_state, differentiate_sleep, false)
      elsif @next_state_type == :legacy_category
        map_state(numeric_state, differentiate_sleep, true)
      end
    end

    def map_state(numeric_state, differentiate_sleep, legacy_titles=false)
      mapped_state = case numeric_state
        when 1, 2, 3, 4, 6
          if differentiate_sleep
            numeric_state == 6  ? :rem : :nrem
          else
            :sleep
          end
        when 5
          :wake
        when 9
          :lights_on
        else
          :undef
      end

      if legacy_titles
        titleize_state(mapped_state)
      else
        mapped_state
      end
    end

    def titleize_state(s)
      if [:nrem, :rem].include? s
        s.to_s.upcase
      else
        s.to_s.titleize
      end
    end
  end
end