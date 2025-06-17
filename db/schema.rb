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

ActiveRecord::Schema[8.0].define(version: 2025_06_17_000634) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "migration_guard_records", force: :cascade do |t|
    t.string "version", null: false
    t.string "branch"
    t.string "author"
    t.string "status"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch", "status"], name: "index_migration_guard_records_on_branch_and_status"
    t.index ["created_at"], name: "index_migration_guard_records_on_created_at"
    t.index ["status"], name: "index_migration_guard_records_on_status"
    t.index ["version"], name: "index_migration_guard_records_on_version", unique: true
  end
end
