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

ActiveRecord::Schema.define(version: 20160513173928) do

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "groceries", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "description",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id",         limit: 4
    t.integer  "user_group_id",    limit: 4
    t.datetime "finished_at"
    t.integer  "grocery_store_id", limit: 4
  end

  add_index "groceries", ["grocery_store_id"], name: "index_groceries_on_grocery_store_id", using: :btree
  add_index "groceries", ["user_group_id"], name: "index_groceries_on_user_group_id", using: :btree

  create_table "groceries_items", force: :cascade do |t|
    t.integer "item_id",      limit: 4,             null: false
    t.integer "grocery_id",   limit: 4,             null: false
    t.integer "quantity",     limit: 4, default: 1
    t.integer "price_cents",  limit: 4, default: 0
    t.integer "requester_id", limit: 4
  end

  add_index "groceries_items", ["grocery_id"], name: "index_groceries_items_on_grocery_id", using: :btree
  add_index "groceries_items", ["item_id", "grocery_id"], name: "index_groceries_items_on_item_id_and_grocery_id", unique: true, using: :btree

  create_table "groceries_recipes", id: false, force: :cascade do |t|
    t.integer "grocery_id", limit: 4, null: false
    t.integer "recipe_id",  limit: 4, null: false
  end

  create_table "grocery_stores", force: :cascade do |t|
    t.string  "name",     limit: 255
    t.decimal "lat",                  precision: 10, scale: 6
    t.decimal "lng",                  precision: 10, scale: 6
    t.string  "place_id", limit: 255
  end

  add_index "grocery_stores", ["lat"], name: "index_grocery_stores_on_lat", using: :btree
  add_index "grocery_stores", ["lng"], name: "index_grocery_stores_on_lng", using: :btree
  add_index "grocery_stores", ["place_id"], name: "index_grocery_stores_on_place_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grocery_id",  limit: 4
  end

  add_index "items", ["grocery_id"], name: "index_items_on_grocery_id", using: :btree
  add_index "items", ["name"], name: "index_items_on_name", using: :btree

  create_table "items_recipes", id: false, force: :cascade do |t|
    t.integer "item_id",   limit: 4, null: false
    t.integer "recipe_id", limit: 4, null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer "grocery_id",  limit: 4
    t.integer "user_id",     limit: 4
    t.integer "price_cents", limit: 4, default: 0
  end

  add_index "payments", ["grocery_id"], name: "index_payments_on_grocery_id", using: :btree
  add_index "payments", ["user_id", "grocery_id"], name: "index_payments_on_user_id_and_grocery_id", unique: true, using: :btree

  create_table "recipes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_groups", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "description",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "emblem",              limit: 255
    t.string   "privacy",             limit: 255
    t.string   "banner_file_name",    limit: 255
    t.string   "banner_content_type", limit: 255
    t.integer  "banner_file_size",    limit: 4
    t.datetime "banner_updated_at"
  end

  create_table "user_groups_users", force: :cascade do |t|
    t.integer "user_group_id", limit: 4,                       null: false
    t.integer "user_id",       limit: 4,                       null: false
    t.string  "state",         limit: 255, default: "invited"
  end

  add_index "user_groups_users", ["user_group_id"], name: "index_user_groups_users_on_user_group_id", using: :btree
  add_index "user_groups_users", ["user_id", "user_group_id"], name: "index_user_groups_users_on_user_id_and_user_group_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                           limit: 255, null: false
    t.string   "crypted_password",                limit: 255
    t.string   "salt",                            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token",               limit: 255
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token",            limit: 255
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "name",                            limit: 255
    t.integer  "roles_mask",                      limit: 4
    t.string   "activation_state",                limit: 255
    t.string   "activation_token",                limit: 255
    t.datetime "activation_token_expires_at"
    t.integer  "user_group_default_id",           limit: 4
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree
  add_index "users", ["user_group_default_id"], name: "index_users_on_user_group_default_id", using: :btree

end
