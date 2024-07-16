# frozen_string_literal: true

class GoogleGmail < ApplicationRecord
  FULL_WIDTH_CHARS = '　！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～'
  HALF_WIDTH_CHARS = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

  # @param [Google::Apis::GmailV1::Message] message Google::Apis::GmailV1::Message
  def self.create_or_update_by_message_id(message)
    record = make_record(message)
    email = find_or_initialize_by(message_id: record[:message_id])
    email.update(record)
  end

  #
  # make_record
  #
  # @param [Google::Apis::GmailV1::Message] message Google::Apis::GmailV1::Message
  #
  # @return [Hash] <description>
  #
  def self.make_record(message)
    body = get_body(message)
    if body.present?
      body_plain_text = HtmlCleanerService.html_to_plain_text(body)
      body_plain_text_half_width = body_plain_text.tr(FULL_WIDTH_CHARS, HALF_WIDTH_CHARS)
    end

    {
      message_id: message.id,
      sender: message.payload.headers.find { |h| h.name == 'From' }&.value,
      subject: message.payload.headers.find { |h| h.name == 'Subject' }&.value,
      body:,
      body_plain_text:,
      body_plain_text_half_width:,
      received_at: Time.at(message.internal_date.to_i / 1000)
    }
  end

  def self.get_body(msg)
    if msg.payload.body.data
      decode_body(msg.payload.body.data)
    elsif msg.payload.parts
      part = msg.payload.parts.find { |p| p.mime_type == 'text/plain' }
      part ? decode_body(part.body.data) : nil
    end
  end

  def self.decode_body(data)
    data.force_encoding('UTF-8')
  end

  def property_price
    Extractor::PropertyPriceService.new(sender_email_domain, body_plain_text_half_width).run
  end

  def sender_email_domain
    email_regex = /\b[A-Za-z0-9._%+-]+@([A-Za-z0-9.-]+\.[A-Z|a-z]{2,})\b/i
    sender.scan(email_regex).flatten.first
  end

  def sender_email_address
    email_regex = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/
    sender.scan(email_regex).first
  end
end
