# frozen_string_literal: true

# Copyright (c) Matthew Podwysocki. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

module Azure
  module NotificationHubs
    # This class represents a notification to be sent to Notification Hubs
    class Notification
      attr_accessor :body, :headers, :content_type, :platform

      def initialize(body, headers, content_type, platform)
        @body = body
        @headers = headers
        @content_type = content_type
        @platform = platform
      end
    end

    # This class represents a notification response
    class NotificationResponse
      attr_reader :location, :tracking_id, :correlation_id

      def initialize(location, tracking_id, correlation_id)
        @location = location
        @tracking_id = tracking_id
        @correlation_id = correlation_id
      end
    end
  end
end
