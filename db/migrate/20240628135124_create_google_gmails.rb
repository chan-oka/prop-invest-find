# frozen_string_literal: true

class CreateGoogleGmails < ActiveRecord::Migration[7.1]
  def change
    create_table :google_gmails do |t|
      t.string :message_id
      t.string :from
      t.string :subject
      t.text :body
      t.datetime :received_at

      t.timestamps
    end
    add_index :google_gmails, :message_id, unique: true
  end
end
