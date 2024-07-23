# frozen_string_literal: true

module Google
  class GmailsController < ApplicationController
    def index
      google_gmails = []
      GoogleGmail.order(received_at: :desc).each do |google_gmail|
        separatd_texts = Extractor::PropertySeparatorService.new(
          google_gmail.sender_email_domain,
          google_gmail.body_plain_text_half_width
        ).run
        if separatd_texts.present?
          separatd_texts.each do |separatd_text|
            copy_google_gmail = google_gmail.deep_dup
            copy_google_gmail.body_plain_text_half_width = separatd_text
            google_gmails.push(copy_google_gmail)
          end
        else
          google_gmails.push(google_gmail)
        end
      end

      @google_gmails = google_gmails
    end
  end
end
