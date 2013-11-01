## Planning and Documentation


### Possible Targets for Loaded Data

Specific column in one of these models: 
- Subject - special treatment
  
#### NEED SUBJECT
- Study
- Irb
- Publication

#### NEEDS SUBJECT + RELATION TO SUBJECT
- Researcher
  *should include :association key*

#### NEEDS STUDY
- Study Nickname
  *should be included in study hash*


#### SPECIAL
*right now have to be supplied, cannot come from file contents*
- Source
- Documentation

#### EVENT
*defined by event dictionary definition (need to supply valid event name)*
*can be added through validation, or directly*
possible fields:
- labtime 
- realtime
- data value 
  *through valid data hash*

### Loading of row of data into database
#### General Notes
- group columns by type of object they will be populating
- create multiple hashes that can be passed on to individual model initializers
- allow events to be mass-loaded with direct_create (option for that)
- other objects must be created through validation path
  
### Example Inputs:
#### Column Mappings

##### General Mapping Strategy
1. Provide column map with behavior defined for each column.

2. Parse this column map into a general mapping structure
  - combine columns by type
  - validate the information structure

3. Use this parsed mapping for loading data into the database in a determined order
  1. Subject
  2.  Subject-depenent objects
      - IRB
      - STUDY (+ any nicknames)
      - PUBLICATION
      - RESEARCHER
  3. Events

##### Example Column Mapping
*Index of hash corresponds to index of column in spreadsheet*
*Make sure this is also representable as JSON and YAML*

    [
      {
        target: [:subject, :study, :event, ...],
        field: [:subject_code, :official_study_name, :<data_tile>, ...],
        
        definitive: [true, false] # default is false. true if field should be included in find_by: list for the given target
        multiple: [true, false] # default is false, true if multiple, semi-colon seperated. If semi-colon seperated, fields ==> array


        event_name: <name> # required only if target == :event or :datum),
        researcher_type: [:pi, :pl] # required only if target == :researcher
      }, 
      {
        ...
      },
      ...
    ]

##### Example Static Field + Existing Record Mapping
[
  class: <Class Name>,
  existing_records: {...},
  static_fields: {
    <list of static fields + values>
  },

  # Event + Data:
  event_name: <event_name>,
  static_data_fields: {
    <list of static data fields + values>
  }
]

##### Example Parsed Mapping
This needs to make it easy to get row and create individual object hashes from it.

In addition, the mapping must make it easy to delete all matching objects before creation starts, if so instructed by the existing data option.

If the existing data option instead outlines a need for updating existing objects, the
mapping has to allow for a quick search for this existing object. 

The mapping also has to provide information on what event dictionary records need to be loaded
    
The mapping provides information for generating models for each ROW of data. 
IF a given model is reused across rows, how the hell do we do that?????

A model can either be reused across all rows being input (since rows are input per file),
or change in each row. We CANNOT have models reused for parts of the file if they are not defined row by row.

Destroy + create ==> creation per row.
Find + update ==> find and update per row. Cannot use direct_create for events

Every mapping besides subject has to also have a subject_id. Researcher needs type + subject_id

    # Normal Objects
    {
      class: Subject,
      existing_records: { action: <:append, :update, :destroy>, find_by: [fields to find by] },
      column_fields: {
        subject_code: <index OR column header> # decide if header support is needed or not,
        ...
      },
      # Fields that do not change for individual rows
      static_fields: {
        disempanneled: false
      }
    },

    # Events
    {
      class: Event,
      existing_records: ...,
      column_fields: {
        realtime: <realtime>,
        labtime: <labtime>,
        documentation_id: <did>,
        source_id: <sid>,

        <data_title>: <index OR column header>,
        ...
      },
      static_fields: {
        epoch_length: 30,

      }
      column_data_fields {

      },
      static_data_fields {

      }
    }
###### Actual Example

    {
      {:class=>Subject(id: integer, subject_code: string, admit_date: datetime, discharge_date: datetime, disempanelled: boolean, t_drive_location: string, notes: text, study_id: integer, deleted: boolean, created_at: datetime, updated_at: datetime), :existing_records=>{:action=>:update, :find_by=>:subject_code}, :column_fields=>{:subject_code=>0, :t_drive_location=>1, :admit_date=>8, :discharge_date=>9, :disempanelled=>10, :notes=>16}},
      {
        :class=>Study, 
        :existing_records => {
          :action=>:update, 
          :find_by=>:official_study_name
        }, 
        :column_fields => {
          :official_study_name=>2, 
          :study_nicknames=>3
        }
      }
      {:class=>Researcher(id: integer, first_name: string, last_name: string, email: string, notes: text, deleted: boolean, created_at: datetime, updated_at: datetime), :existing_records=>{:action=>:update, :find_by=>[:first_name, :last_name]}, :column_fields=>{:full_name=>6}, :researcher_type=>:pi}
      {:class=>Researcher(id: integer, first_name: string, last_name: string, email: string, notes: text, deleted: boolean, created_at: datetime, updated_at: datetime), :existing_records=>{:action=>:update, :find_by=>[:first_name, :last_name]}, :column_fields=>{:full_name=>7}, :researcher_type=>:pl}
      {:class=>Irb(id: integer, title: string, number: string, deleted: boolean, created_at: datetime, updated_at: datetime), :existing_records=>{:action=>:update, :find_by=>:irb_number}, :column_fields=>{:irb_name=>4, :irb_number=>5}}
      {
        :class=>Event, 
        :existing_records => {:action=>:destroy, :find_by=>[:name, :subject_id]}, 
        :column_fields => {}, 
        :static_fields => {:realtime=>Tue, 19 Mar 2013 19:04:11 EDT -04:00}, 
        :event_name => :forced_desynchrony_study_information, 
        :event_dictionary => <EventDictionary>, 
        :data_fields => {
          :age_group=>11, 
          :t_cycle=>12, 
          :sleep_period_duration=>13, 
          :wake_period_duration=>14, 
          :intervention=>15
        }
      }
    }

##### Actual Object Creation
1. Subject gets treated first:
  - If not given as a parameter, then MUST exist as a hash



##### Validations




#### Data Row

### Algorithm
1.

#### Behavior Regarding Existing Data
##### Possible Actions
- destroy and create
- find or create
- create

##### Notes
The behavior has to be defined for each type of mapping; namely, each possible major object (Subject, Study, Irb, etc.), and each type of event (one mapping for each event name).

- :find_by option must exist to instruct what params to find existing objects by*
- append is default
- update raises error if more than one object found
- destroy should destroy the collection only ONE TIME at the beginning OF CURRENT TRANSACTION

##### Example Hash:
{existing_records: {action: <:append, :update, :destroy>, find_by: [fields to find by]}
      

## File-Specific Data Mappings

### Subject Information Files
#### Main Information
- subject_code => Subject
- t_drive_location => Subject
- official_study_name => Study
- study_nicknames => Study#study_nicknames
- irb_names => IRB
- irb_numbers => IRB
- principal_investigator => Researcher
- project_leader => Researcher
- admit_date => Subject
- discharge_date => Subject
- disempanelled => Subject
- notes => Subject

#### Study-Specific Information
**Types of studies and study information has to be better-defined!!**

##### Forced De-synchrony
*event name:* forced_desynchrony_study_information
- age_group => Event
- t_cycle => Event ^
- sleep_period_duration => Event ^
- wake_period_duration => Event ^
- intervention => Event ^

##### Light
*event name:* monochromatic_light_intervention
- monochromatic_light_wavelength
- monochromatic_light_irradiance_target
- monochromatic_light_photon_flux_target
- monochromatic_light_irradiance_measured
- monochromatic_light_photon_flux_measured
*event name:* polychromatic_light_intervention
- polychromatic_light_source
- polychromatic_light_level_target
- polychromatic_light_level_measured
