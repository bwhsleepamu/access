module ETL
  class ValidationError < StandardError; end

  def ETL.load_subject_list(list_dir)
    subject_info = {}
    Dir.foreach(list_dir) do |file|
      next if file == '.' or file == '..'
      csv_file = CSV.open("#{list_dir}/#{file}", {headers: true})
      subject_code = /(.*)\.csv/i.match(File.basename(csv_file.path))[1].upcase

      subject_info[subject_code] = []
      csv_file.each do |row|
        file_info = {}
        pattern = /(.*)\.man/i.match(row[0])
        file_info[:start_time] = row[1]
        file_info[:start_labtime] = row[2].to_f
        file_info[:last_line_number] = row[3].to_i
        file_info[:last_line_time] = row[4]
        file_info[:last_line_labtime] = row[5].to_f

        if pattern
          file_info[:pattern] = pattern[1]
          simple_match = /(.*)_\S+(\d{2})_(.*)/i.match(file_info[:pattern])
          year = simple_match[2].to_i
          file_info[:year] = year + (year > 60 ? 1900 : 2000)
          file_info[:simple_pattern] = "#{simple_match[1]}#{simple_match[3]}".downcase
          subject_info[subject_code] << file_info
        else
          MY_LOG.info "No Valid File Name Found: #{row}"
          next
        end
      end
    end
    MY_LOG.info subject_info.inspect
    subject_info
  end
end