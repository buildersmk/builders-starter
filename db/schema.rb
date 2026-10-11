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

ActiveRecord::Schema[8.1].define(version: 2026_10_11_000001) do
  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain"
    t.string "plan", default: "free", null: false
    t.datetime "plan_since"
    t.string "stripe_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_customer_id"], name: "index_accounts_on_stripe_customer_id", unique: true, where: "stripe_customer_id IS NOT NULL"
    t.index ["subdomain"], name: "index_accounts_on_subdomain", unique: true, where: "subdomain IS NOT NULL"
  end

  create_table "identities", force: :cascade do |t|
    t.string "email_address", null: false
    t.datetime "email_confirmed_at"
    t.string "login_code_digest"
    t.datetime "login_code_sent_at"
    t.integer "login_code_attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_identities_on_email_address", unique: true
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.integer "identity_id"
    t.string "endpoint", null: false
    t.string "p256dh", null: false
    t.string "auth", null: false
    t.datetime "gave_up_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["identity_id"], name: "index_push_subscriptions_on_identity_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "identity_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_sessions_on_identity_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "identity_id"
    t.string "name", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "identity_id"], name: "index_users_on_account_id_and_identity_id", unique: true
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["identity_id"], name: "index_users_on_identity_id"
  end

  add_foreign_key "push_subscriptions", "identities"
  add_foreign_key "sessions", "identities"
  add_foreign_key "users", "accounts"
  add_foreign_key "users", "identities"
end
