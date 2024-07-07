# frozen_string_literal: true

class GmailFetchStatus < ApplicationRecord
  enum fetch_type: { differential: 'differential', full: 'full' }

  validates :fetch_type, presence: true

  def self.find_or_create(fetch_type)
    find_or_create_by(fetch_type:)
  end
end
