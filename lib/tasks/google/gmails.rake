# frozen_string_literal: true

namespace :google do
  namespace :gmails do
    desc 'Fetch emails from Gmail'
    task fetch_all: :environment do
      puts 'Starting to fetch emails...'

      gmail_service = Google::GmailService.new
      emails = gmail_service.fetch_emails

      emails.each do |email_data|
        GoogleGmail.create(email_data)
      end
      puts 'Finished fetching emails.'
    end

    desc 'Fetch unread emails from Gmail and mark them as read'
    task fetch_unread: :environment do
      puts 'Starting to fetch unread emails...'
      begin
        service = Google::GmailService.new
        emails = service.fetch_unread_emails
        puts "Successfully fetched #{emails.size} unread emails"
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
        puts e.backtrace.join("\n")
      end
    end
  end
end
