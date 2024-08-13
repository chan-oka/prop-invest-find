# frozen_string_literal: true

module Extractor
  class PropertySeparatorService
    def initialize(sender_email_domain, text)
      @sender_email_domain = sender_email_domain
      @text = text
      @extraction_patterns = ExtractionPattern.separator_only.group_by(&:sender_email_domain)
    end

    def run
      return [] if @text.nil?
      return [] if @text.empty?
      return [] if fetch_patterns.nil?

      separat.map do |separatd|
        { name: separatd.first, text: separatd.second }
      end
    end

    private

    def separat
      @text.scan(fetch_patterns.first)
    end

    def fetch_patterns
      return @fetch_patterns if @fetch_patterns.present?

      extraction_patterns = @extraction_patterns.fetch(@sender_email_domain, nil)
      return nil if extraction_patterns.nil?

      @fetch_patterns = extraction_patterns.map(&:pattern_unescape)
      @fetch_patterns
    end
  end
end
