# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140501200602) do

  create_table "authentications", force: true do |t|
    t.integer  "user_id",    precision: 38, scale: 0
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "change_logs", force: true do |t|
    t.integer  "model_id",         precision: 38, scale: 0
    t.integer  "source_id",        precision: 38, scale: 0
    t.integer  "documentation_id", precision: 38, scale: 0
    t.integer  "user_id",          precision: 38, scale: 0
    t.string   "action_type"
    t.datetime "timestamp"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "change_logs", ["action_type"], name: "i_change_logs_action_type"
  add_index "change_logs", ["documentation_id"], name: "i_change_logs_documentation_id"
  add_index "change_logs", ["model_id"], name: "index_change_logs_on_model_id"
  add_index "change_logs", ["source_id"], name: "index_change_logs_on_source_id"
  add_index "change_logs", ["user_id"], name: "index_change_logs_on_user_id"

  create_table "data", force: true do |t|
    t.string   "title"
    t.text     "notes"
    t.integer  "source_id",        precision: 38, scale: 0
    t.integer  "documentation_id", precision: 38, scale: 0
    t.boolean  "deleted",          precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "event_id",         precision: 38, scale: 0
  end

  add_index "data", ["deleted"], name: "index_data_on_deleted"
  add_index "data", ["documentation_id"], name: "index_data_on_documentation_id"
  add_index "data", ["event_id"], name: "index_data_on_event_id"
  add_index "data", ["source_id"], name: "index_data_on_source_id"
  add_index "data", ["title"], name: "index_data_on_title"

  create_table "data_dictionary", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "data_type_id",        precision: 38, scale: 0
    t.integer  "min_value_id",        precision: 38, scale: 0
    t.boolean  "min_value_inclusive", precision: 1,  scale: 0
    t.integer  "max_value_id",        precision: 38, scale: 0
    t.boolean  "max_value_inclusive", precision: 1,  scale: 0
    t.boolean  "multivalue",          precision: 1,  scale: 0, default: false
    t.integer  "min_length",          precision: 38, scale: 0
    t.string   "unit"
    t.boolean  "deleted",             precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "max_length",          precision: 38, scale: 0
  end

  add_index "data_dictionary", ["data_type_id"], name: "i_data_dictionary_data_type_id"
  add_index "data_dictionary", ["max_value_id"], name: "i_data_dictionary_max_value_id"
  add_index "data_dictionary", ["min_value_id"], name: "i_data_dictionary_min_value_id"
  add_index "data_dictionary", ["title"], name: "index_data_dictionary_on_title"

  create_table "data_dictionary_data_values", force: true do |t|
    t.integer  "data_dictionary_id", precision: 38, scale: 0
    t.integer  "data_value_id",      precision: 38, scale: 0
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "data_dictionary_data_values", ["data_dictionary_id", "data_value_id"], name: "i88e160c7ed5756e0202b47c0ec24b"
  add_index "data_dictionary_data_values", ["data_dictionary_id"], name: "i_dat_dic_dat_val_dat_dic_id"
  add_index "data_dictionary_data_values", ["data_value_id"], name: "i_dat_dic_dat_val_dat_val_id"

  create_table "data_quality_flags", force: true do |t|
    t.integer  "datum_id",        precision: 38, scale: 0
    t.integer  "quality_flag_id", precision: 38, scale: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "data_quality_flags", ["datum_id"], name: "i_data_quality_flags_datum_id"
  add_index "data_quality_flags", ["quality_flag_id"], name: "i_dat_qua_fla_qua_fla_id"

  create_table "data_types", force: true do |t|
    t.string   "name"
    t.string   "storage"
    t.boolean  "range",      precision: 1, scale: 0
    t.boolean  "length",     precision: 1, scale: 0
    t.boolean  "values",     precision: 1, scale: 0
    t.boolean  "multiple",   precision: 1, scale: 0
    t.boolean  "deleted",    precision: 1, scale: 0, default: false, null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "data_types", ["deleted"], name: "index_data_types_on_deleted"
  add_index "data_types", ["name"], name: "index_data_types_on_name"

  create_table "data_values", force: true do |t|
    t.decimal  "num_value"
    t.string   "text_value"
    t.datetime "time_value"
    t.string   "type_flag"
    t.boolean  "deleted",         precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "datum_id",        precision: 38, scale: 0
    t.integer  "time_offset_sec", precision: 38, scale: 0
  end

  add_index "data_values", ["datum_id"], name: "index_data_values_on_datum_id"
  add_index "data_values", ["deleted"], name: "index_data_values_on_deleted"
  add_index "data_values", ["type_flag"], name: "index_data_values_on_type_flag"

  create_table "documentation_links", force: true do |t|
    t.integer "documentation_id", precision: 38, scale: 0
    t.string  "title"
    t.string  "path"
  end

  add_index "documentation_links", ["documentation_id"], name: "i_doc_lin_doc_id"

  create_table "documentations", force: true do |t|
    t.string   "title"
    t.string   "author"
    t.string   "origin_location"
    t.text     "description"
    t.integer  "user_id",         precision: 38, scale: 0
    t.boolean  "deleted",         precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "documentations", ["author"], name: "index_documentations_on_author"
  add_index "documentations", ["deleted"], name: "i_documentations_deleted"
  add_index "documentations", ["title", "author"], name: "i_documentations_title_author"
  add_index "documentations", ["title"], name: "index_documentations_on_title"
  add_index "documentations", ["user_id"], name: "i_documentations_user_id"

  create_table "event_dictionary", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "deleted",     precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "paired_id",   precision: 38, scale: 0
  end

  add_index "event_dictionary", ["deleted"], name: "i_event_dictionary_deleted"
  add_index "event_dictionary", ["name"], name: "index_event_dictionary_on_name"

  create_table "event_dictionary_data_fields", force: true do |t|
    t.integer  "event_dictionary_id", precision: 38, scale: 0
    t.integer  "data_dictionary_id",  precision: 38, scale: 0
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "event_dictionary_data_fields", ["data_dictionary_id"], name: "i_eve_dic_dat_fie_dat_dic_id"
  add_index "event_dictionary_data_fields", ["event_dictionary_id", "data_dictionary_id"], name: "i53c7931601d1841ba03490671f0f6"
  add_index "event_dictionary_data_fields", ["event_dictionary_id"], name: "i_eve_dic_dat_fie_eve_dic_id"

  create_table "event_dictionary_event_tags", force: true do |t|
    t.integer  "event_dictionary_id", precision: 38, scale: 0
    t.integer  "event_tag_id",        precision: 38, scale: 0
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "event_dictionary_event_tags", ["event_dictionary_id", "event_tag_id"], name: "icb0b22ad188f720e7f407a5e2c4dc"
  add_index "event_dictionary_event_tags", ["event_dictionary_id"], name: "i_eve_dic_eve_tag_eve_dic_id"
  add_index "event_dictionary_event_tags", ["event_tag_id"], name: "i_eve_dic_eve_tag_eve_tag_id"

  create_table "event_quality_flags", force: true do |t|
    t.integer  "event_id",        precision: 38, scale: 0
    t.integer  "quality_flag_id", precision: 38, scale: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "event_quality_flags", ["event_id", "quality_flag_id"], name: "i9a9de6fe8c0758b7b5b5551512306"
  add_index "event_quality_flags", ["event_id"], name: "i_event_quality_flags_event_id"
  add_index "event_quality_flags", ["quality_flag_id"], name: "i_eve_qua_fla_qua_fla_id"

  create_table "event_tags", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "deleted",     precision: 1, scale: 0, default: false, null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "event_tags", ["deleted"], name: "index_event_tags_on_deleted"
  add_index "event_tags", ["name"], name: "index_event_tags_on_name"

  create_table "events", force: true do |t|
    t.string   "name"
    t.text     "notes"
    t.integer  "subject_id",          precision: 38, scale: 0
    t.integer  "source_id",           precision: 38, scale: 0
    t.integer  "documentation_id",    precision: 38, scale: 0
    t.integer  "labtime_hour",        precision: 38, scale: 0
    t.integer  "labtime_min",         precision: 38, scale: 0
    t.integer  "labtime_sec",         precision: 38, scale: 0
    t.integer  "labtime_year",        precision: 38, scale: 0
    t.datetime "realtime"
    t.integer  "group_label",         precision: 38, scale: 0
    t.boolean  "deleted",             precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "labtime_timezone"
    t.integer  "realtime_offset_sec", precision: 38, scale: 0
  end

  add_index "events", ["deleted"], name: "index_events_on_deleted"
  add_index "events", ["documentation_id"], name: "i_events_documentation_id"
  add_index "events", ["group_label"], name: "index_events_on_group_label"
  add_index "events", ["labtime_hour", "labtime_min", "labtime_sec", "labtime_year"], name: "i8f5fc7b11407564e207f28864a565"
  add_index "events", ["name", "id"], name: "index_events_on_id_name"
  add_index "events", ["name"], name: "index_events_on_name"
  add_index "events", ["realtime"], name: "index_events_on_realtime"
  add_index "events", ["source_id"], name: "index_events_on_source_id"
  add_index "events", ["subject_id", "name"], name: "index_events_on_s_id_name"
  add_index "events", ["subject_id"], name: "index_events_on_subject_id"

  create_table "irbs", force: true do |t|
    t.string   "title"
    t.string   "irb_number"
    t.boolean  "deleted",    precision: 1, scale: 0, default: false, null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "irbs", ["deleted"], name: "index_irbs_on_deleted"
  add_index "irbs", ["irb_number"], name: "index_irbs_on_irb_number"

  create_table "publications", force: true do |t|
    t.integer  "pubmed_id",  precision: 38, scale: 0
    t.integer  "endnote_id", precision: 38, scale: 0
    t.string   "title"
    t.string   "authors"
    t.string   "journal"
    t.string   "year"
    t.text     "notes"
    t.boolean  "deleted",    precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "publications", ["deleted"], name: "index_publications_on_deleted"
  add_index "publications", ["pubmed_id"], name: "i_publications_pubmed_id"
  add_index "publications", ["title"], name: "index_publications_on_title"

  create_table "quality_flags", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "deleted",     precision: 1, scale: 0, default: false, null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "quality_flags", ["deleted"], name: "index_quality_flags_on_deleted"
  add_index "quality_flags", ["name"], name: "index_quality_flags_on_name"

  create_table "researchers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "notes"
    t.boolean  "deleted",    precision: 1, scale: 0, default: false, null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "researchers", ["deleted"], name: "index_researchers_on_deleted"
  add_index "researchers", ["email"], name: "index_researchers_on_email"
  add_index "researchers", ["first_name", "last_name"], name: "i_res_fir_nam_las_nam"
  add_index "researchers", ["last_name"], name: "index_researchers_on_last_name"

  create_table "source_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "deleted",          precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "documentation_id", precision: 38, scale: 0
    t.string   "file_pattern"
  end

  add_index "source_types", ["deleted"], name: "index_source_types_on_deleted"
  add_index "source_types", ["documentation_id"], name: "i_sou_typ_doc_id"
  add_index "source_types", ["name"], name: "index_source_types_on_name"

  create_table "sources", force: true do |t|
    t.integer  "source_type_id",    precision: 38, scale: 0
    t.integer  "user_id",           precision: 38, scale: 0
    t.string   "location"
    t.text     "description"
    t.boolean  "deleted",           precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.text     "notes"
    t.integer  "parent_id",         precision: 38, scale: 0
    t.string   "original_location"
    t.integer  "subject_id",        precision: 38, scale: 0
    t.text     "column_map"
    t.string   "worksheet_name"
    t.integer  "documentation_id",  precision: 38, scale: 0
  end

  add_index "sources", ["deleted"], name: "index_sources_on_deleted"
  add_index "sources", ["documentation_id"], name: "i_sources_documentation_id"
  add_index "sources", ["location"], name: "index_sources_on_location"
  add_index "sources", ["parent_id"], name: "index_sources_on_parent_id"
  add_index "sources", ["source_type_id"], name: "i_sources_source_type_id"
  add_index "sources", ["user_id"], name: "index_sources_on_user_id"

  create_table "studies", force: true do |t|
    t.string   "official_name"
    t.text     "description"
    t.boolean  "deleted",       precision: 1, scale: 0, default: false, null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "studies", ["deleted"], name: "index_studies_on_deleted"
  add_index "studies", ["official_name"], name: "index_studies_on_official_name"

  create_table "study_nicknames", force: true do |t|
    t.integer  "study_id",   precision: 38, scale: 0
    t.string   "nickname"
    t.boolean  "deleted",    precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "study_nicknames", ["deleted"], name: "i_study_nicknames_deleted"
  add_index "study_nicknames", ["nickname"], name: "i_study_nicknames_nickname"
  add_index "study_nicknames", ["study_id"], name: "i_study_nicknames_study_id"

  create_table "'subject'_groups", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "deleted",     precision: 1, scale: 0, default: false, null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "subject_groups", ["name"], name: "index_subject_tags_on_name"

  create_table "subjects", force: true do |t|
    t.string   "subject_code"
    t.boolean  "disempanelled",    precision: 1,  scale: 0
    t.string   "t_drive_location"
    t.text     "notes"
    t.integer  "study_id",         precision: 38, scale: 0
    t.boolean  "deleted",          precision: 1,  scale: 0, default: false, null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "admit_day",        precision: 38, scale: 0
    t.integer  "admit_month",      precision: 38, scale: 0
    t.integer  "admit_year",       precision: 38, scale: 0
    t.integer  "discharge_day",    precision: 38, scale: 0
    t.integer  "discharge_month",  precision: 38, scale: 0
    t.integer  "discharge_year",   precision: 38, scale: 0
  end

  add_index "subjects", ["deleted"], name: "index_subjects_on_deleted"
  add_index "subjects", ["study_id"], name: "index_subjects_on_study_id"
  add_index "subjects", ["subject_code"], name: "index_subjects_on_subject_code"

  create_table "subjects_irbs", force: true do |t|
    t.integer  "subject_id", precision: 38, scale: 0
    t.integer  "irb_id",     precision: 38, scale: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "subjects_irbs", ["irb_id"], name: "index_subjects_irbs_on_irb_id"
  add_index "subjects_irbs", ["subject_id", "irb_id"], name: "i_sub_irb_sub_id_irb_id"
  add_index "subjects_irbs", ["subject_id"], name: "i_subjects_irbs_subject_id"

  create_table "subjects_pis", force: true do |t|
    t.integer  "researcher_id", precision: 38, scale: 0
    t.integer  "subject_id",    precision: 38, scale: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "subjects_pis", ["researcher_id", "subject_id"], name: "i_sub_pis_res_id_sub_id"
  add_index "subjects_pis", ["researcher_id"], name: "i_subjects_pis_researcher_id"
  add_index "subjects_pis", ["subject_id"], name: "i_subjects_pis_subject_id"

  create_table "subjects_project_leaders", force: true do |t|
    t.integer  "researcher_id", precision: 38, scale: 0
    t.integer  "subject_id",    precision: 38, scale: 0
    t.string   "role"
    t.text     "notes"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "subjects_project_leaders", ["researcher_id", "subject_id"], name: "i_sub_pro_lea_res_id_sub_id"
  add_index "subjects_project_leaders", ["researcher_id"], name: "i_sub_pro_lea_res_id"
  add_index "subjects_project_leaders", ["role"], name: "i_sub_pro_lea_rol"
  add_index "subjects_project_leaders", ["subject_id"], name: "i_sub_pro_lea_sub_id"

  create_table "subjects_publications", force: true do |t|
    t.integer  "subject_id",     precision: 38, scale: 0
    t.integer  "publication_id", precision: 38, scale: 0
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "subjects_publications", ["publication_id"], name: "i_sub_pub_pub_id"
  add_index "subjects_publications", ["subject_id", "publication_id"], name: "i_sub_pub_sub_id_pub_id"
  add_index "subjects_publications", ["subject_id"], name: "i_sub_pub_sub_id"

  create_table "subjects_subject_groups", force: true do |t|
    t.integer "subject_id",       precision: 38, scale: 0
    t.integer "subject_group_id", precision: 38, scale: 0
  end

  add_index "subjects_subject_groups", ["subject_group_id"], name: "i_sub_sub_tag_sub_tag_id"
  add_index "subjects_subject_groups", ["subject_id"], name: "i_sub_sub_tag_sub_id"

  create_table "supporting_documentations", force: true do |t|
    t.integer "parent_id", precision: 38, scale: 0
    t.integer "child_id",  precision: 38, scale: 0
  end

  add_index "supporting_documentations", ["child_id"], name: "i_sup_doc_chi_id"
  add_index "supporting_documentations", ["parent_id"], name: "i_sup_doc_par_id"

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status",                                          default: "pending", null: false
    t.boolean  "deleted",                precision: 1,  scale: 0, default: false,     null: false
    t.boolean  "system_admin",           precision: 1,  scale: 0, default: false,     null: false
    t.string   "email",                                           default: ""
    t.string   "encrypted_password",                              default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          precision: 38, scale: 0, default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        precision: 38, scale: 0, default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
  end

  add_index "users", ["authentication_token"], name: "i_users_authentication_token", unique: true
  add_index "users", ["confirmation_token"], name: "i_users_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "i_users_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

  add_foreign_key "data", "documentations", name: "data_documentation_id_fk"
  add_foreign_key "data", "events", name: "data_event_id_fk", dependent: :delete
  add_foreign_key "data", "sources", name: "data_source_id_fk"

  add_foreign_key "data_dictionary", "data_types", name: "dat_dic_dat_typ_id_fk"
  add_foreign_key "data_dictionary", "data_values", column: "max_value_id", name: "data_dict_max_value_fk"
  add_foreign_key "data_dictionary", "data_values", column: "min_value_id", name: "data_dict_min_value_fk"

  add_foreign_key "data_dictionary_data_values", "data_dictionary", name: "dat_dic_dat_val_dat_dic_id_fk"
  add_foreign_key "data_dictionary_data_values", "data_values", name: "dat_dic_dat_val_dat_val_id_fk"

  add_foreign_key "data_quality_flags", "data", name: "data_quality_flags_datum_id_fk"
  add_foreign_key "data_quality_flags", "quality_flags", name: "dat_qua_fla_qua_fla_id_fk"

  add_foreign_key "data_values", "data", name: "datum_id_fk", dependent: :delete

  add_foreign_key "documentation_links", "documentations", name: "doc_lin_doc_id_fk"

  add_foreign_key "documentations", "users", name: "documentations_user_id_fk"

  add_foreign_key "event_dictionary", "event_dictionary", column: "paired_id", name: "event_dictionary_paired_id_fk", dependent: :nullify

  add_foreign_key "event_dictionary_data_fields", "data_dictionary", name: "eve_dic_dat_fie_dat_dic_id_fk"
  add_foreign_key "event_dictionary_data_fields", "event_dictionary", name: "eve_dic_dat_fie_eve_dic_id_fk"

  add_foreign_key "event_dictionary_event_tags", "event_dictionary", name: "eve_dic_eve_tag_eve_dic_id_fk"
  add_foreign_key "event_dictionary_event_tags", "event_tags", name: "eve_dic_eve_tag_eve_tag_id_fk"

  add_foreign_key "event_quality_flags", "events", name: "eve_qua_fla_eve_id_fk"
  add_foreign_key "event_quality_flags", "quality_flags", name: "eve_qua_fla_qua_fla_id_fk"

  add_foreign_key "events", "documentations", name: "events_documentation_id_fk"
  add_foreign_key "events", "sources", name: "events_source_id_fk"
  add_foreign_key "events", "subjects", name: "events_subject_id_fk"

  add_foreign_key "source_types", "documentations", name: "sou_typ_doc_id_fk", dependent: :nullify

  add_foreign_key "sources", "documentations", name: "sources_documentation_id_fk", dependent: :nullify
  add_foreign_key "sources", "source_types", name: "sources_source_type_id_fk"
  add_foreign_key "sources", "sources", column: "parent_id", name: "sources_parent_id_fk", dependent: :nullify
  add_foreign_key "sources", "users", name: "sources_user_id_fk"

  add_foreign_key "study_nicknames", "studies", name: "study_nicknames_study_id_fk", dependent: :delete

  add_foreign_key "subjects", "studies", name: "subjects_study_id_fk", dependent: :nullify

  add_foreign_key "subjects_irbs", "irbs", name: "subjects_irbs_irb_id_fk", dependent: :delete
  add_foreign_key "subjects_irbs", "subjects", name: "subjects_irbs_subject_id_fk", dependent: :delete

  add_foreign_key "subjects_pis", "researchers", name: "subjects_pis_researcher_id_fk", dependent: :delete
  add_foreign_key "subjects_pis", "subjects", name: "subjects_pis_subject_id_fk", dependent: :delete

  add_foreign_key "subjects_project_leaders", "researchers", name: "sub_pro_lea_res_id_fk", dependent: :delete
  add_foreign_key "subjects_project_leaders", "subjects", name: "sub_pro_lea_sub_id_fk", dependent: :delete

  add_foreign_key "subjects_publications", "publications", name: "sub_pub_pub_id_fk"
  add_foreign_key "subjects_publications", "subjects", name: "sub_pub_sub_id_fk"

  add_foreign_key "subjects_subject_groups", "subject_groups", name: "sub_sub_gro_sub_gro_id_fk", dependent: :delete
  add_foreign_key "subjects_subject_groups", "subjects", name: "sub_sub_gro_sub_id_fk", dependent: :delete

  add_foreign_key "supporting_documentations", "documentations", column: "child_id", name: "sup_doc_chi_id_fk"
  add_foreign_key "supporting_documentations", "documentations", column: "parent_id", name: "sup_doc_par_id_fk"

end
