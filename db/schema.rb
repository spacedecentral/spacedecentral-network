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

ActiveRecord::Schema.define(version: 20180205220723) do

  create_table "activities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type"
    t.text     "activity",   limit: 65535
    t.integer  "user_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "contacts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "email"
    t.string   "subject"
    t.text     "message",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "conversations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_2_id"
    t.integer  "message_id"
    t.boolean  "read",       default: false
    t.integer  "group_size"
    t.index ["message_id"], name: "index_conversations_on_message_id", using: :btree
    t.index ["user_id"], name: "index_conversations_on_user_id", using: :btree
  end

  create_table "followings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "follow_user"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["user_id"], name: "index_followings_on_user_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, length: { slug: 70, scope: 70 }, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }, using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "g_drive_files", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "direct_link"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "mission_id"
    t.string   "icon_link"
    t.index ["mission_id"], name: "index_g_drive_files_on_mission_id", using: :btree
    t.index ["user_id"], name: "index_g_drive_files_on_user_id", using: :btree
  end

  create_table "group_convo_references", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.boolean  "read",            default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["conversation_id"], name: "index_group_convo_references_on_conversation_id", using: :btree
    t.index ["user_id"], name: "index_group_convo_references_on_user_id", using: :btree
  end

  create_table "likes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "likable_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "likable_type"
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "body",              limit: 65535
    t.integer  "user_id"
    t.integer  "user_to"
    t.integer  "conversation_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "read",                            default: false
    t.integer  "mission_id"
    t.integer  "conversation_2_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id", using: :btree
    t.index ["mission_id"], name: "index_messages_on_mission_id", using: :btree
    t.index ["user_id"], name: "index_messages_on_user_id", using: :btree
  end

  create_table "mission_user_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "role"
    t.integer  "mission_id"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "pending"
    t.text     "contribute",   limit: 65535
    t.string   "availability"
    t.index ["mission_id"], name: "index_mission_user_roles_on_mission_id", using: :btree
    t.index ["user_id"], name: "index_mission_user_roles_on_user_id", using: :btree
  end

  create_table "missions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.text     "objectives",         limit: 4294967295
    t.integer  "cover_dy"
    t.string   "gdrive_folder_id"
    t.string   "slug"
    t.integer  "parent"
    t.integer  "object_type",                           default: 1
    t.integer  "members_count",                         default: 0
    t.index ["slug"], name: "index_missions_on_slug", unique: true, using: :btree
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "event"
    t.integer  "from_user"
    t.boolean  "read",            default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.string   "template"
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "posts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.text     "content",       limit: 65535
    t.integer  "user_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "slug"
    t.integer  "replies_count",               default: 0
    t.integer  "likes_count",                 default: 0
    t.integer  "post_type",                   default: 0
    t.string   "postable_type"
    t.integer  "postable_id"
    t.index ["postable_id"], name: "index_posts_on_postable_id", using: :btree
    t.index ["slug"], name: "index_posts_on_slug", unique: true, using: :btree
    t.index ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at", using: :btree
    t.index ["user_id"], name: "index_posts_on_user_id", using: :btree
  end

  create_table "publication_authors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "author"
    t.integer  "user_publication_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "user_id"
    t.index ["user_id"], name: "index_publication_authors_on_user_id", using: :btree
    t.index ["user_publication_id"], name: "index_publication_authors_on_user_publication_id", using: :btree
  end

  create_table "publication_long_lats", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.float    "longitude",           limit: 24
    t.float    "latitude",            limit: 24
    t.float    "max_long",            limit: 24
    t.float    "max_lat",             limit: 24
    t.integer  "user_publication_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "planet"
    t.index ["user_publication_id"], name: "index_publication_long_lats_on_user_publication_id", using: :btree
  end

  create_table "replies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "content",         limit: 65535
    t.integer  "user_id"
    t.integer  "replicable_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "replicable_type"
    t.integer  "likes_count",                   default: 0
    t.integer  "replies_count",                 default: 0
    t.index ["replicable_id"], name: "index_replies_on_replicable_id", using: :btree
    t.index ["user_id", "replicable_id", "created_at"], name: "index_replies_on_user_id_and_replicable_id_and_created_at", using: :btree
    t.index ["user_id"], name: "index_replies_on_user_id", using: :btree
  end

  create_table "report_contents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "reportable_type"
    t.integer  "reportable_id"
    t.integer  "report_type"
    t.string   "report_parent_type"
    t.integer  "report_parent_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["report_parent_id"], name: "index_report_contents_on_report_parent_id", using: :btree
    t.index ["reportable_id"], name: "index_report_contents_on_reportable_id", using: :btree
    t.index ["user_id"], name: "index_report_contents_on_user_id", using: :btree
  end

  create_table "shares", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user"
    t.integer  "post"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tag_references", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "tag_id"
    t.integer  "post_id"
    t.integer  "user_publication_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "user_id"
    t.integer  "mission_id"
    t.index ["mission_id"], name: "fk_rails_329de12adc", using: :btree
    t.index ["post_id"], name: "index_tag_references_on_post_id", using: :btree
    t.index ["tag_id"], name: "index_tag_references_on_tag_id", using: :btree
    t.index ["user_id"], name: "index_tag_references_on_user_id", using: :btree
    t.index ["user_publication_id"], name: "index_tag_references_on_user_publication_id", using: :btree
  end

  create_table "tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_careers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "position"
    t.string   "company"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.index ["user_id"], name: "index_user_careers_on_user_id", using: :btree
  end

  create_table "user_educations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "degree"
    t.string   "school"
    t.string   "graduation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.index ["user_id"], name: "index_user_educations_on_user_id", using: :btree
  end

  create_table "user_publication_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_publication_id"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["user_id"], name: "index_user_publication_permissions_on_user_id", using: :btree
    t.index ["user_publication_id"], name: "index_user_publication_permissions_on_user_publication_id", using: :btree
  end

  create_table "user_publications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "summary"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "paper_file_name"
    t.string   "paper_content_type"
    t.integer  "paper_file_size"
    t.datetime "paper_updated_at"
    t.string   "kml_file_file_name"
    t.string   "kml_file_content_type"
    t.integer  "kml_file_file_size"
    t.datetime "kml_file_updated_at"
    t.string   "title"
    t.string   "publisher"
    t.text     "abstract",              limit: 65535
    t.string   "doi"
    t.date     "publication_date"
    t.string   "publication_url"
    t.string   "volume"
    t.string   "issue"
    t.string   "arXiv"
    t.integer  "PMID"
    t.boolean  "keep_private"
    t.integer  "likes_count",                         default: 0
    t.integer  "replies_count",                       default: 0
    t.text     "additional_authors",    limit: 65535
    t.string   "slug",                  limit: 400
    t.index ["user_id"], name: "index_user_publications_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                                  default: "", null: false
    t.string   "encrypted_password",                     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "role"
    t.integer  "cover_dy"
    t.text     "bio",                      limit: 65535
    t.string   "provider"
    t.string   "string"
    t.string   "uid"
    t.string   "name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "cover_photo_file_name"
    t.string   "cover_photo_content_type"
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string   "location"
    t.string   "title"
    t.string   "linkedin_url"
    t.string   "username"
    t.boolean  "newsletter"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", using: :btree
  end

  add_foreign_key "activities", "users"
  add_foreign_key "conversations", "messages"
  add_foreign_key "conversations", "users"
  add_foreign_key "followings", "users"
  add_foreign_key "g_drive_files", "missions"
  add_foreign_key "g_drive_files", "users"
  add_foreign_key "group_convo_references", "conversations"
  add_foreign_key "group_convo_references", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "missions"
  add_foreign_key "messages", "users"
  add_foreign_key "mission_user_roles", "missions"
  add_foreign_key "mission_user_roles", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "publication_authors", "user_publications"
  add_foreign_key "publication_long_lats", "user_publications"
  add_foreign_key "replies", "users"
  add_foreign_key "tag_references", "missions"
  add_foreign_key "tag_references", "posts"
  add_foreign_key "tag_references", "tags"
  add_foreign_key "tag_references", "user_publications"
  add_foreign_key "tag_references", "users"
  add_foreign_key "user_careers", "users"
  add_foreign_key "user_educations", "users"
  add_foreign_key "user_publication_permissions", "user_publications"
  add_foreign_key "user_publication_permissions", "users"
  add_foreign_key "user_publications", "users"
end
