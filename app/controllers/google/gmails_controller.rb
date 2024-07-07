# frozen_string_literal: true

module Google
  class GmailsController < ApplicationController
    def index
      @google_gmails = GoogleGmail.order(received_at: :desc)
    end
  end
end
