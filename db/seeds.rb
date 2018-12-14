# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
###
###
# create_table "subject_groups", force: :cascade do |t|
#     t.string   "name"
#     t.text     "description"
#     t.boolean  "deleted",     limit: nil, default: false, null: false
#     t.datetime "created_at",                              null: false
#     t.datetime "updated_at",                              null: false
#   end



# get the date formate right and run again!
# SubjectGroup.create(name:"secondtest", description:"secondtesttest",created_at:DateTime.now.strftime("%d/%m/%Y"),updated_at:DateTime.now.strftime("%d/%m/%Y"))

#   create_table "subjects", force: :cascade do |t|
# t.string   "subject_code"
# t.boolean  "disempanelled",    limit: nil
# t.string   "t_drive_location"
# t.text     "notes"
# t.integer  "study_id",                     precision: 38
# t.boolean  "deleted",          limit: nil,                default: false, null: false
# t.datetime "created_at",                                                  null: false
# t.datetime "updated_at",                                                  null: false
# t.integer  "admit_month",                  precision: 38
# t.integer  "study_year",                   precision: 38
# t.integer  "discharge_month",              precision: 38
# end



# Subject.create(
#     subject_code: "3411GX52",
#     study_id: 19333775,
#     created_at: DateTime.now.strftime("%d/%m/%Y"),
#     updated_at: DateTime.now.strftime("%d/%m/%Y")
#     )


# create_table "subjects_irbs", force: :cascade do |t|
#     t.integer  "subject_id", precision: 38
#     t.integer  "irb_id",     precision: 38
#     t.datetime "created_at",                null: false
#     t.datetime "updated_at",                null: false
#   end

#   SubjectsIrb.create(
#       subject_id: 108778806,
#       irb_id: 19333778,
#       created_at: DateTime.now.strftime("%d/%m/%Y"),
#       updated_at: DateTime.now.strftime("%d/%m/%Y")

#   )




# SubjectsPi.create(
#     subject_id: 108778806,
#     researcher_id: 19333280,
#     created_at: DateTime.now.strftime("%d/%m/%Y"),
#     updated_at: DateTime.now.strftime("%d/%m/%Y")
# )


# Researcher.create(
#     first_name: "Andrew",
#     last_name: "McHill",
#     created_at: DateTime.now.strftime("%d/%m/%Y"),
#     updated_at: DateTime.now.strftime("%d/%m/%Y")
# )

# SubjectsProjectLeader.create(

#     researcher_id: 108778826,
#     subject_id: 108778806,
#     role: "current",
#     created_at: DateTime.now.strftime("%d/%m/%Y"),
#     updated_at: DateTime.now.strftime("%d/%m/%Y")
# )

# # add more nicknames (executed)
# StudyNickname.create(
#     study_id: 19336160,
#     nickname: "NIA PPG 1990 28hr day",
#     deleted: false,
#     created_at: DateTime.now.strftime("%d/%m/%Y"),
#     updated_at: DateTime.now.strftime("%d/%m/%Y")
# )