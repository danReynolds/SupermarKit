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

ActiveRecord::Schema.define(version: 20161126174755) do

  create_table "authentications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_authentications_on_user_id", using: :btree
  end

  create_table "groceries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "user_group_id"
    t.datetime "finished_at"
    t.integer  "grocery_store_id"
    t.string   "receipt_file_name"
    t.string   "receipt_content_type"
    t.integer  "receipt_file_size"
    t.datetime "receipt_updated_at"
    t.index ["grocery_store_id"], name: "index_groceries_on_grocery_store_id", using: :btree
    t.index ["user_group_id"], name: "index_groceries_on_user_group_id", using: :btree
  end

  create_table "groceries_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "item_id",                                               null: false
    t.integer "grocery_id",                                            null: false
    t.decimal "quantity",     precision: 16, scale: 2, default: "1.0"
    t.integer "price_cents",                           default: 0
    t.integer "requester_id"
    t.string  "units"
    t.index ["grocery_id"], name: "index_groceries_items_on_grocery_id", using: :btree
    t.index ["item_id", "grocery_id"], name: "index_groceries_items_on_item_id_and_grocery_id", unique: true, using: :btree
  end

  create_table "groceries_recipes", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "grocery_id", null: false
    t.integer "recipe_id",  null: false
  end

  create_table "grocery_payments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "grocery_id"
    t.integer  "user_id"
    t.integer  "price_cents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["grocery_id"], name: "index_grocery_payments_on_grocery_id", using: :btree
    t.index ["user_id", "grocery_id"], name: "index_grocery_payments_on_user_id_and_grocery_id", unique: true, using: :btree
  end

  create_table "grocery_stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name"
    t.decimal "lat",      precision: 10, scale: 6
    t.decimal "lng",      precision: 10, scale: 6
    t.string  "place_id"
    t.index ["lat"], name: "index_grocery_stores_on_lat", using: :btree
    t.index ["lng"], name: "index_grocery_stores_on_lng", using: :btree
    t.index ["place_id"], name: "index_grocery_stores_on_place_id", using: :btree
  end

  create_table "items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grocery_id"
    t.index ["grocery_id"], name: "index_items_on_grocery_id", using: :btree
    t.index ["name"], name: "index_items_on_name", using: :btree
  end

  create_table "items_recipes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "item_id",                                            null: false
    t.integer "recipe_id",                                          null: false
    t.string  "units"
    t.decimal "quantity",  precision: 16, scale: 2, default: "1.0"
  end

  create_table "recipes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_url"
    t.integer  "rating"
    t.integer  "timeInSeconds"
    t.string   "external_id"
  end

  create_table "slack_bots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "api_token"
    t.integer "user_group_id"
  end

  create_table "slack_messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "format"
    t.string  "message_type"
    t.integer "slack_bot_id"
    t.boolean "enabled",      default: false
  end

  create_table "user_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "emblem"
    t.string   "privacy"
    t.string   "banner_file_name"
    t.string   "banner_content_type"
    t.integer  "banner_file_size"
    t.datetime "banner_updated_at"
    t.integer  "owner_id"
  end

  create_table "user_groups_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_group_id",                     null: false
    t.integer "user_id",                           null: false
    t.string  "state",         default: "invited"
    t.index ["user_group_id"], name: "index_user_groups_users_on_user_group_id", using: :btree
    t.index ["user_id", "user_group_id"], name: "index_user_groups_users_on_user_id_and_user_group_id", unique: true, using: :btree
  end

  create_table "user_payments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "price_cents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payer_id"
    t.integer  "payee_id"
    t.integer  "user_group_id"
    t.string   "reason"
    t.index ["payee_id"], name: "index_user_payments_on_payee_id", using: :btree
    t.index ["payer_id"], name: "index_user_payments_on_payer_id", using: :btree
    t.index ["user_group_id"], name: "index_user_payments_on_user_group_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                           null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "name"
    t.integer  "roles_mask"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.integer  "user_group_default_id"
    t.index ["activation_token"], name: "index_users_on_activation_token", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree
    t.index ["user_group_default_id"], name: "index_users_on_user_group_default_id", using: :btree
  end

end
