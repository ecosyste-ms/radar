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

ActiveRecord::Schema[8.0].define(version: 2023_09_06_140037) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "dependent_packages", force: :cascade do |t|
    t.integer "package_id"
    t.string "name"
    t.string "resolved_versions", default: [], array: true
    t.string "resolved_major_versions", default: [], array: true
    t.string "resolved_minor_versions", default: [], array: true
    t.string "resolved_patch_versions", default: [], array: true
    t.json "package_fields"
    t.json "versions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dependent_repositories", force: :cascade do |t|
    t.integer "package_id"
    t.string "full_name"
    t.string "resolved_versions", default: [], array: true
    t.string "resolved_major_versions", default: [], array: true
    t.string "resolved_minor_versions", default: [], array: true
    t.string "resolved_patch_versions", default: [], array: true
    t.boolean "direct_dependency"
    t.json "repository_fields"
    t.json "manifests"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "packages", force: :cascade do |t|
    t.integer "registry_id"
    t.string "name"
    t.string "ecosystem"
    t.text "description"
    t.text "keywords"
    t.string "homepage"
    t.string "licenses"
    t.string "repository_url"
    t.string "normalized_licenses"
    t.integer "versions_count"
    t.datetime "latest_release_published_at"
    t.string "latest_release_number"
    t.string "keywords_array"
    t.string "language"
    t.string "status"
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "advisories", default: []
    t.bigint "last_dependency_id"
    t.integer "dependent_repositories_count", default: 0
    t.integer "dependent_packages_count", default: 0
    t.integer "last_package_dependency_id"
  end

  create_table "registries", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "ecosystem"
    t.boolean "default"
    t.integer "packages_count"
    t.string "github"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.integer "package_id"
    t.string "number"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
