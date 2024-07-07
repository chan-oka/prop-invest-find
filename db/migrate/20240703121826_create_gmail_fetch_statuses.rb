# frozen_string_literal: true

class CreateGmailFetchStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :gmail_fetch_statuses do |t|
      t.string :last_message_id
      t.datetime :last_fetch_at
      t.date :last_processed_date
      t.string :fetch_type
      t.timestamps
    end
  end
end
