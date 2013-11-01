require 'spec_helper'

## Input:
# Data: subject code, sleep period #, labtime, sleep stage
# Options: min bout length == X, epoch length(if not from database data)
# The input can come from scored_epoch events as well. In that case, only the subject code need be supplied

## Output:
# 1. Sleep bouts
# 2. Wake bouts
# 3. Rem bouts
# 4. NREM bouts
#
# Each line: subject_code  start_labtime  bout_length  censored  next_state

describe Tools::BoutMaker do

  before do
    @data_location = "/usr/local/htdocs/access/spec/data/bout_maker_data"
    @subject_code = "2844GX"
    @query_results = YAML.load(File.read("/usr/local/htdocs/access/spec/data/bout_maker_data/sql_output.robj"))
    @input_data = @query_results.map{|epoch| [@subject_code, 1, epoch["labtime"], epoch["scored_stage"]]}
    @full_input_data = YAML.load(File.read("/usr/local/htdocs/access/spec/data/bout_maker_data/full_input_data.robj"))

    @simple_input = YAML.load(File.read("/usr/local/htdocs/access/spec/data/bout_maker_data/simple_input_2.robj"))
    @min_length = 3
    @epoch_length = 0.5
  end


  it "Validates input data" do
    @query_results.length.should == 1477
    @input_data.length.should == 1477
  end

  describe "Simple Input" do
    # Output for simple data:
    let(:sleep_desired_output) { [["2844GX", 1, 2013.064, 2.5, 0, 5], ["2844GX", 1, 2013.131, 4.5, 0, 5], ["2844GX", 1, 2013.239, 6.5, 1, "."], ["2844GX", 1, 2013.423, 2.0, 1, "."], ["2844GX", 2, 2013.564, 2.0, 0, 5], ["2844GX", 2, 2013.631, 7.5, 1, "."]] }
    let(:wake_desired_output) { [["2844GX", 1, 2013.106, 1.5, 0, 1], ["2844GX", 1, 2013.206, 2, 0, 6], ["2844GX", 1, 2013.381, 2.5, 0, 1], ["2844GX", 2, 2013.598, 2.0, 0, 1]] }
    let(:rem_desired_output) { [["2844GX", 1, 2013.181, 1.5, 0, 5], ["2844GX", 1, 2013.239, 3, 0, 1], ["2844GX", 2, 2013.564, 2.0, 0, 5], ["2844GX", 2, 2013.723, 2.0, 1, "."]] }
    let(:nrem_desired_output) { [["2844GX", 1, 2013.064, 2.5, 0, 5], ["2844GX", 1, 2013.131, 3, 0, 6], ["2844GX", 1, 2013.289, 3.5, 1, "."], ["2844GX", 1, 2013.423, 2.0, 1, "."], ["2844GX", 2, 2013.631, 5.5, 0, 6]] }

    it "should return desired output for simple input" do

      [[:sleep_bouts, sleep_desired_output], [:wake_bouts, wake_desired_output], [:rem_bouts, rem_desired_output], [:nrem_bouts, nrem_desired_output]].each do |method, desired_output|
        bm = Tools::BoutMaker.new(@simple_input, @min_length, @epoch_length)
        bouts = bm.send(method)
        expect(bouts.length).to eq(desired_output.length), "#{method}: #{bouts.length}\n#{bouts}"
        bouts = bouts.map {|x| [x[0], x[1], x[2].round(3), x[3], x[4], x[5]]}
        bouts.each_with_index do |b, i|
          b.should == desired_output[i]
        end
        bouts.should == desired_output
      end
    end

    it "should return non-numeric next states" do
      [[:sleep_bouts, sleep_desired_output], [:wake_bouts, wake_desired_output], [:rem_bouts, rem_desired_output], [:nrem_bouts, nrem_desired_output]].each do |method, desired_output|
        bm = Tools::BoutMaker.new(@simple_input, @min_length, @epoch_length, :legacy_category)
        bouts = bm.send(method)
        expect(bouts.length).to eq(desired_output.length), "#{method}: #{bouts.length}\n#{bouts}"
        next_states = bouts.map{|x| x[5]}.uniq.to_set
        expect(next_states).to be_proper_subset(["Sleep", "Wake", "NREM", "REM", "."].to_set), "#{next_states.to_a}"
      end
    end

    it "should work for bouts of min length == 2" do
      pending
    end

  end

  describe "Full Dataset" do
    it "should run" do
      bm = Tools::BoutMaker.new(@input_data, @min_length, @epoch_length)

      [:sleep_bouts, :wake_bouts, :rem_bouts, :nrem_bouts].each do |method|
        r = bm.send(method)
        r.length.should > 0
      end

    end

    it "should create files that match the previous program's output" do
      bm = Tools::BoutMaker.new(@full_input_data, 2, 0.5, :legacy_category)

      [:sleep, :wake, :rem, :nrem].each do |method|
        r = bm.send(method.to_s+"_bouts")
        my_file_path = Tools::BoutMaker.to_file(@subject_code, method, 2, 0.5, r, @data_location)
        #my_file = File.open(my_file_path)
        test_file = File.open(File.join(@data_location, "#{method.to_s}_test.csv"))

        my_file_length = IO.popen("wc -l #{my_file_path}").readline.split(" ")[0].to_i
        test_file_length = IO.popen("wc -l #{test_file.path}").readline.split(" ")[0].to_i

        expect(my_file_length).to eq(test_file_length)
      end
    end
  end

end