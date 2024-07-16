# frozen_string_literal: true

class ExtractionPattern < ApplicationRecord
  enum pattern_type: { price: 'price' }

  validates :pattern_type, presence: true
  validates :pattern, presence: true

  scope :price_only, -> { where(pattern_type: :price) }

  def pattern_unescape
    Regexp.new(pattern)
  end
end
