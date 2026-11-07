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

ActiveRecord::Schema[8.1].define(version: 2026_11_07_050006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "bentos", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "bento_type", null: false
    t.integer "price", null: false
    t.boolean "on_sale", default: true, null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "bento_type::text = ANY (ARRAY['japanese'::character varying, 'western'::character varying, 'chinese'::character varying, 'healthy'::character varying]::text[])", name: "bentos_bento_type_check"
    t.check_constraint "price >= 0", name: "bentos_price_check"
  end

  create_table "daily_menus", force: :cascade do |t|
    t.date "served_on", null: false
    t.bigint "bento_id", null: false
    t.integer "stock_limit", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bento_id"], name: "index_daily_menus_on_bento_id"
    t.index ["served_on", "bento_id"], name: "index_daily_menus_on_served_on_and_bento_id", unique: true
    t.check_constraint "stock_limit >= 0", name: "daily_menus_stock_limit_check"
  end

  create_table "delivery_areas", force: :cascade do |t|
    t.string "name", null: false
    t.string "postal_code", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["postal_code"], name: "index_delivery_areas_on_postal_code", unique: true
    t.check_constraint "postal_code::text ~ '^[0-9]{7}$'::text", name: "delivery_areas_postal_code_check"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "daily_menu_id", null: false
    t.integer "quantity", null: false
    t.bigint "delivery_area_id", null: false
    t.string "delivery_address", null: false
    t.integer "unit_price", null: false
    t.integer "discount_per_unit", null: false
    t.integer "total_price", null: false
    t.string "status", default: "ordered", null: false
    t.bigint "subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_menu_id"], name: "index_orders_on_daily_menu_id"
    t.index ["delivery_area_id"], name: "index_orders_on_delivery_area_id"
    t.index ["subscription_id"], name: "index_orders_on_subscription_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.check_constraint "discount_per_unit >= 0", name: "orders_discount_per_unit_check"
    t.check_constraint "quantity >= 1 AND quantity <= 3", name: "orders_quantity_check"
    t.check_constraint "status::text = ANY (ARRAY['ordered'::character varying, 'received'::character varying, 'canceled'::character varying]::text[])", name: "orders_status_check"
    t.check_constraint "total_price >= 0", name: "orders_total_price_check"
    t.check_constraint "unit_price >= 0", name: "orders_unit_price_check"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_reviews_on_order_id", unique: true
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_check"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "wday", null: false
    t.string "bento_type", null: false
    t.integer "quantity", null: false
    t.bigint "delivery_area_id", null: false
    t.string "delivery_address", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_area_id"], name: "index_subscriptions_on_delivery_area_id"
    t.index ["user_id", "wday"], name: "index_subscriptions_on_user_id_and_wday", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
    t.check_constraint "bento_type::text = ANY (ARRAY['japanese'::character varying, 'western'::character varying, 'chinese'::character varying, 'healthy'::character varying]::text[])", name: "subscriptions_bento_type_check"
    t.check_constraint "quantity >= 1 AND quantity <= 3", name: "subscriptions_quantity_check"
    t.check_constraint "wday >= 1 AND wday <= 5", name: "subscriptions_wday_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "phone_number", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "daily_menus", "bentos"
  add_foreign_key "orders", "daily_menus"
  add_foreign_key "orders", "delivery_areas"
  add_foreign_key "orders", "subscriptions"
  add_foreign_key "orders", "users"
  add_foreign_key "reviews", "orders"
  add_foreign_key "subscriptions", "delivery_areas"
  add_foreign_key "subscriptions", "users"
end
