# frozen_string_literal: true

class CreateGoogleGmails < ActiveRecord::Migration[7.1]
  def change
    create_table :google_gmails do |t|
      t.string :message_id
      t.string :sender
      t.string :subject
      t.text :body
      t.text :body_plain_text
      t.text :body_plain_text_half_width
      t.datetime :received_at

      t.timestamps
    end
    add_index :google_gmails, :message_id, unique: true
  end
end
