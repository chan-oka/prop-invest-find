# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_240_711_134_125) do
  create_table 'extraction_patterns', charset: 'utf8mb4', collation: 'utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string 'sender_email_domain'
    t.string 'pattern_type'
    t.text 'pattern', null: false
    t.text 'description'
    t.integer 'priority', default: 0
    t.boolean 'is_active', default: true
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['is_active'], name: 'index_extraction_patterns_on_is_active'
    t.index ['sender_email_domain'], name: 'index_extraction_patterns_on_sender_email_domain'
  end

  create_table 'gmail_fetch_statuses', charset: 'utf8mb4', collation: 'utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string 'last_message_id'
    t.datetime 'last_fetch_at'
    t.date 'last_processed_date'
    t.string 'fetch_type'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'google_gmails', charset: 'utf8mb4', collation: 'utf8mb4_0900_ai_ci', force: :cascade do |t|
    t.string 'message_id'
    t.string 'sender'
    t.string 'subject'
    t.text 'body'
    t.text 'body_plain_text'
    t.text 'body_plain_text_half_width'
    t.datetime 'received_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['message_id'], name: 'index_google_gmails_on_message_id', unique: true
  end
end
