# frozen_string_literal: true

require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

module Google
  class GmailService
    CLIENT_SECRETS_PATH = Rails.root.join('config', 'client_secrets.json')
    CREDENTIALS_PATH = File.join(Dir.home, '.credentials', 'gmail-ruby-quickstart.yaml')
    SCOPE = [
      Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
      Google::Apis::GmailV1::AUTH_GMAIL_MODIFY
    ].freeze
    BATCH_SIZE = 100

    def initialize
      @service = Google::Apis::GmailV1::GmailService.new
      @service.authorization = authorize
    end

    def fetch_all_emails
      Rails.logger.info 'Fetching all emails...'
      status = GmailFetchStatus.find_or_create(GmailFetchStatus.fetch_types[:full])
      start_date = status.last_processed_date || 5.years.ago.to_date
      end_date = Date.today

      status.update(last_processed_date: nil, last_message_id: nil)
      fetch_emails_for_date_range(start_date, end_date, status, unread_only: false)
    end

    def fetch_unread_emails
      Rails.logger.info 'Fetching new unread emails...'
      status = GmailFetchStatus.find_or_create(GmailFetchStatus.fetch_types[:differential])
      start_date = status.last_processed_date || 1.day.ago.to_date
      end_date = Date.today

      fetch_emails_for_date_range(start_date, end_date, status, unread_only: true)
    end

    def user_message(id)
      @service.get_user_message('me', id)
    end

    # private

    def fetch_emails_for_date_range(start_date, end_date, status, unread_only:)
      (start_date..end_date).each do |date|
        fetch_emails_for_date(date, status, unread_only)
      end
    end

    def fetch_emails_for_date(date, status, unread_only)
      Rails.logger.info "Processing emails for date: #{date}"
      query = build_query(date, unread_only)
      page_token = nil
      total_processed = 0

      loop do
        result = fetch_messages(query, page_token)
        message_ids = result.messages&.map(&:id) || []

        break if message_ids.empty?

        process_messages(message_ids)

        total_processed += message_ids.size
        update_fetch_status(message_ids.first, total_processed, status)

        Rails.logger.info "Processed #{total_processed} emails for date #{date}"

        page_token = result.next_page_token
        break if page_token.nil?
      end

      return unless total_processed.positive?

      status.update(last_processed_date: date, last_message_id: nil)
      Rails.logger.info "Completed processing for date #{date}. Total emails processed: #{total_processed}"
    end

    def build_query(date, unread_only)
      query = "after:#{date} before:#{date + 1.day}"
      query = "is:unread #{query}" if unread_only
      query
    end

    def fetch_messages(query, page_token)
      Rails.logger.info "Fetching messages with query: #{query}"

      begin
        result = @service.list_user_messages('me',
                                             q: query,
                                             max_results: BATCH_SIZE,
                                             page_token:)
        Rails.logger.info "Fetched #{result.messages&.size || 0} messages"
        Rails.logger.info "Next page token: #{result.next_page_token}"
        result
      rescue StandardError => e
        Rails.logger.error "Error fetching messages: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        raise
      end
    end

    def process_messages(message_ids)
      messages_to_mark_read = []
      message_ids.each do |id|
        msg = @service.get_user_message('me', id)

        GoogleGmail.create_or_update_by_message_id(msg)

        messages_to_mark_read << id if msg.label_ids&.include?('UNREAD')
      rescue StandardError => e
        Rails.logger.error "Error processing message #{id}: #{e.message}"
      end
      messages_to_mark_read = []
      mark_messages_as_read(messages_to_mark_read) if messages_to_mark_read.present?
    end

    def mark_messages_as_read(message_ids)
      return if message_ids.empty?

      batch_request = ::Google::Apis::GmailV1::BatchModifyMessagesRequest.new(
        ids: message_ids,
        remove_label_ids: ['UNREAD']
      )

      @service.batch_modify_messages('me', batch_request)
      Rails.logger.info "Marked #{message_ids.size} messages as read"
    rescue StandardError => e
      Rails.logger.error "Error marking messages as read: #{e.message}"
    end

    def update_fetch_status(last_message_id, total_processed, status)
      status.update(
        last_message_id:,
        last_fetch_at: Time.current
      )
      Rails.logger.info "Updated fetch status. Last message ID: #{last_message_id}, Total processed: #{total_processed}"
    end

    def authorize
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'

      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
        puts 'Open the following URL in the browser and enter the resulting code after authorization:'
        puts url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id:, code:, base_url: 'urn:ietf:wg:oauth:2.0:oob'
        )
      elsif credentials.expired?
        begin
          credentials.refresh!
        rescue Signet::AuthorizationError
          # リフレッシュに失敗した場合、新しい認証を要求
          token_store.delete(user_id)
          return authorize # 再帰的に呼び出し
        end
      end
      credentials
    end
  end
end
