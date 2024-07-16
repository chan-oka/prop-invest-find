# frozen_string_literal: true

class CreateExtractionPatterns < ActiveRecord::Migration[7.1]
  def change
    create_table :extraction_patterns do |t|
      t.string :sender_email_domain
      t.string :pattern_type
      t.text :pattern, null: false
      t.text :description
      t.integer :priority, default: 0
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :extraction_patterns, :sender_email_domain
    add_index :extraction_patterns, :is_active
  end
end
