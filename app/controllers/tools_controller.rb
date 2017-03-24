require 'tasci_merger'
require 'tempfile'
require 'tmpdir'

class ToolsController < ApplicationController
  before_filter :authenticate_user!



  def tasci_merger
    if params[:subject_code] and params[:tasci_location]
      zip_path = "TasciMergerOutput_#{params[:subject_code]}.zip"
      zipfile = Tempfile.new(zip_path)

      cleaned_path = params["tasci_location"].gsub(/\\/, '/').gsub(/([TXI])\:/, '/\1')

      Dir.mktmpdir do |dir_path|
        tm = TasciMerger.new(params[:subject_code], cleaned_path, dir_path)
        tm.create_master_list
        tm.merge_files


        begin
          Zip::OutputStream.open(zipfile) {|zos|}

          Zip::File.open(zipfile.path, Zip::File::CREATE) do |zip|
            d = Dir.new(dir_path)
            d.each do |file_to_zip|
              zip.add(file_to_zip, d.path + '/' + file_to_zip) unless file_to_zip == '.' or file_to_zip == '..'
            end
          end

          zipfile.close

          zip_data = File.read(zipfile.path)

          send_data(zip_data, type: 'application/zip', filename: zip_path)
        ensure
          zipfile.close
          zipfile.unlink
        end


      end


      # raise "Wait!"
    else
      render :tasci_merger
    end


  end

  private

end
