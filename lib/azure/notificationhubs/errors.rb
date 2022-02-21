# frozen_string_literal: true

# Copyright (c) Matthew Podwysocki. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

module Azure
  module NotificationHubs
    # This class is a custom error for Azure Notification Hubs
    class Error < StandardError
    end

    # This class represents an HTTP error
    class HttpError < Error
      attr_reader :code, :message

      def initialize(code, message)
        super(message)
        @code = code
        @message = message
      end

      def to_s
        "HTTP request failed => #{@code} #{@message}"
      end
    end
  end
end
