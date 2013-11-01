require 'spec_helper'

describe ETL::DbfLoader do
  let(:new_forms_dbf) { "spec/data/TEST_EMPTY.DBF" }
  let(:subject) { create(:subject, subject_code: "3227GX", admit_date: Time.zone.local(2012, 3, 4)) }
  let(:source) { create(:source) }
  let(:documentation) { create(:documentation) }

  before do
    @new_forms_params =
        {
            conditional_columns: [2, 3],
            static_params: {},
            event_groups: [
                [:in_bed_start_scheduled, :in_bed_end_scheduled],
                [:out_of_bed_start_scheduled, :out_of_bed_end_scheduled],
                [:sleep_start_scheduled, :sleep_end_scheduled],
                [:wake_start_scheduled, :wake_end_scheduled],
                [:lighting_block_start_scheduled, :lighting_block_end_scheduled]
            ],
            conditions: {
                [/In Bed/, /005/] => {
                    event_map: [ {name: :in_bed_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :out_of_bed_end_scheduled, existing_records: :destroy, labtime_fn: :from_s} ],
                    column_map: [ {target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                    capture_map: []
                },
                [/Out of Bed/, /005/] => {
                    event_map: [{name: :out_of_bed_start_scheduled, existing_records: :destroy, labtime_fn: :from_s},  {name: :in_bed_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                    column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                    capture_map: []
                },
                [/Lighting Change Lux=(\d+)/, /024/] => {
                    event_map: [{name: :lighting_block_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :lighting_block_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                    column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                    capture_map: [{target: :datum, name: :lighting_block_start_scheduled, field: :light_level}]
                },
                [/Sleep Episode #(\d+) Lux=(\d+)/, /022/] => {
                    event_map: [{name: :lighting_block_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :sleep_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :sleep_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :lighting_block_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                    column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                    capture_map: [
                        {target: :datum, name: :sleep_start_scheduled, field: :episode_number},
                        {target: :datum, name: :lighting_block_start_scheduled, field: :light_level}
                    ]
                },
                [/Wake Time #(\d+) Lux=(\d+)/, /023/] => {
                    event_map: [{name: :lighting_block_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :wake_start_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :wake_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}, {name: :lighting_block_end_scheduled, existing_records: :destroy, labtime_fn: :from_s}],
                    column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :none}, {target: :none}, {target: :subject_code_verification}],
                    capture_map: [
                        {target: :datum, name: :wake_start_scheduled, field: :episode_number},
                        {target: :datum, name: :lighting_block_start_scheduled, field: :light_level}
                    ]
                },
                [] => {
                    event_map: [{name: :new_forms_event, existing_records: :destroy, labtime_fn: :from_s}],
                    column_map: [{target: :event, field: :labtime}, {target: :event, field: :labtime_sec}, {target: :datum, field: :event_description}, {target: :datum, field: :event_code}, {target: :subject_code_verification}],
                    capture_map: []
                }
            }
        }

    create(:dbf_loader_dictionaries)
  end

  it "should correctly load TEST_EMPTY.DBF file" do
    dbf_loader = ETL::DbfLoader.new(new_forms_dbf, @new_forms_params, source, documentation, subject)
    dbf_loader.load

    Event.where("group_label is not null").count.should == Event.where("name != ?", "new_forms_event").count

    Subject.count.should == 1
    Event.where(name: "in_bed_start_scheduled").count.should == 5
    Event.where(name: "in_bed_end_scheduled").count.should == 5
    Event.where(name: "out_of_bed_start_scheduled").count.should == 5
    Event.where(name: "out_of_bed_end_scheduled").count.should == 5
    Event.where(name: "sleep_start_scheduled").count.should == 5
    Event.where(name: "sleep_end_scheduled").count.should == 5
    Event.where(name: "wake_start_scheduled").count.should == 5
    Event.where(name: "wake_end_scheduled").count.should == 5
    Event.where(name: "lighting_block_start_scheduled").count.should == 11
    Event.where(name: "lighting_block_end_scheduled").count.should == 11
    Event.where(name: "new_forms_event").count.should == 746
  end

  it "should not duplicate events if existing records are set to be destroyed" do
    dbf_loader = ETL::DbfLoader.new(new_forms_dbf, @new_forms_params, source, documentation, subject)
    dbf_loader.load

    event_count = Event.count
    event_count.should_not == 0

    dbf_loader2 = ETL::DbfLoader.new(new_forms_dbf, @new_forms_params.clone, source, documentation, subject)
    dbf_loader2.load

    Event.count.should == event_count

  end

end