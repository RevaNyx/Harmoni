# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_12_06_213046) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "recurrence"
    t.bigint "family_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_appointments_on_family_id"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_families_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "due_date"
    t.integer "priority"
    t.integer "status"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id", null: false
    t.index ["family_id"], name: "index_tasks_on_family_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id", null: false
    t.bigint "family_id"
    t.string "username"
    t.string "access_token"
    t.string "refresh_token"
    t.string "account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "appointments", "families"
  add_foreign_key "appointments", "users"
  add_foreign_key "families", "users"
  add_foreign_key "tasks", "families"
  add_foreign_key "tasks", "users"
  add_foreign_key "users", "families"
  add_foreign_key "users", "roles"
end
