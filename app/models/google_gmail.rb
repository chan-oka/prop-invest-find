# frozen_string_literal: true

class GoogleGmail < ApplicationRecord
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
    {
      message_id: message.id,
      from: message.payload.headers.find { |h| h.name == 'From' }&.value,
      subject: message.payload.headers.find { |h| h.name == 'Subject' }&.value,
      body: get_body(message),
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

  def body_plain_text
    HtmlCleanerService.html_to_plain_text(body)
  end
end
