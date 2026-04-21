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

ActiveRecord::Schema[8.1].define(version: 2026_03_22_184810) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "components", force: :cascade do |t|
    t.string "architecture"
    t.string "brand"
    t.string "category"
    t.bigint "computer_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.decimal "price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["computer_id"], name: "index_components_on_computer_id"
  end

  create_table "computer_parts", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.bigint "computer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_computer_parts_on_component_id"
    t.index ["computer_id"], name: "index_computer_parts_on_computer_id"
  end

  create_table "computers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name"
    t.string "string"
    t.string "text"
    t.string "total_price"
    t.datetime "updated_at", null: false
  end

  create_table "testes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "texto"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "components", "computers"
  add_foreign_key "computer_parts", "components"
  add_foreign_key "computer_parts", "computers"
end
