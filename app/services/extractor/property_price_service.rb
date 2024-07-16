# frozen_string_literal: true

module Extractor
  class PropertyPriceService
    def initialize(sender_email_domain, text)
      @sender_email_domain = sender_email_domain
      @text = text
      @extraction_patterns = ExtractionPattern.price_only.group_by(&:sender_email_domain)
    end

    def run
      return [] if @text.nil? || @text.empty?
      return [] if fetch_patterns.nil?

      prices = []

      fetch_patterns.each do |fetch_pattern|
        matches = @text.scan(fetch_pattern)
        matches.each do |match|
          price = match.first
          prices << convert_to_yen(price) if price && !price.empty?
        end
      end

      prices.uniq.sort
    end

    private

    def fetch_patterns
      return @fetch_patterns if @fetch_patterns.present?

      extraction_patterns = @extraction_patterns.fetch(@sender_email_domain, nil)
      return nil if extraction_patterns.nil?

      @fetch_patterns = extraction_patterns.map(&:pattern_unescape)
      @fetch_patterns
    end

    def convert_to_yen(price_string)
      price_string = price_string.gsub(/[^\d億万円\.]/, '') # 数字と単位以外を削除（小数点は保持）
      if price_string.include?('億')
        parts = price_string.split('億')
        (parts[0].to_f * 100_000_000) + (parts[1].to_f * 10_000)
      elsif price_string.include?('万')
        price_string.to_f * 10_000
      else
        price_string.to_f # 円単位の場合はそのまま
      end.to_i
    end
  end
end
