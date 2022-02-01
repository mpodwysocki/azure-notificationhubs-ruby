# frozen_string_literal: true

# Copyright (c) Matthew Podwysocki. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require_relative "errors"
require_relative "notification"
require_relative "token_provider"
require_relative "version"
require "uri"
require "net/http"

module Azure
  module NotificationHubs
    API_VERSION = "2020-06"

    # This class represents actions that cna be done on the Azure Notification Hub
    class NotifcationHub
      def initialize(connection_string, hub_name)
        @hub_name = hub_name
        parsed_connection = parse_connection(connection_string)
        @token_provider = TokenProvider.new(parsed_connection[:key_name], parsed_connection[:key_value])
        @base_uri = parsed_connection[:endpoint]
      end

      def send_direct_notification(notification, device_handle)
        send_notification(notification, device_handle, nil)
      end

      def send_tags_notification(notification, tags)
        send_notification(notification, nil, tags.join("||"))
      end

      def send_tag_expression_notification(notification, tag_expression)
        send_notification(notification, nil, tag_expression)
      end

      private

      def send_notification(notification, device_handle, tag_expression)
        fixed_host = @base_uri.gsub("sb://", "https://")
        target_uri = "#{fixed_host}#{@hub_name}/messages/?api-version=#{API_VERSION}"
        target_uri += "&direct=true" unless device_handle.nil?

        endpoint_uri = URI(target_uri)
        https = Net::HTTP.new(endpoint_uri.host, endpoint_uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(endpoint_uri.path, "Content-Type" => notification.content_type)

        notification&.headers&.each do |key, value|
          request[key] = value
        end

        request["Authorization"] = @token_provider.generate_signature(@base_uri)
        request["ServiceBusNotification-Format"] = notification.platform
        request["ServiceBusNotification-Tags"] = tag_expression unless tag_expression.nil?
        request["ServiceBusNotification-DeviceHandle"] = device_handle unless device_handle.nil?

        puts notification.body
        request.body = notification.body

        response = https.request(request)

        # TODO: Add retry logic
        raise HttpError.new(response.code, response.msg) unless response.code == "201"

        tracking_id = response["TrackingId"]
        location = response["Location"]
        correlation_id = response["x-ms-correlation-request-id"]

        NotificationResponse.new(location, tracking_id, correlation_id)
      end

      def parse_connection(connection_string)
        endpoint = ""
        key_name = ""
        key_value = ""
        splits = connection_string.split(";")
        splits.each do |split|
          key_value_pair = split.split("=")
          raise ArgumentError, "Invalid connection string" unless key_value_pair.length == 2

          key, value = key_value_pair
          endpoint = value if key.casecmp("Endpoint").zero?
          key_name = value if key.casecmp("SharedAccessKeyName").zero?
          key_value = "#{value}=" if key.casecmp("SharedAccessKey").zero?
        end

        raise ArgumentError, "Invalid connection string parts" if endpoint.empty? || key_name.empty? || key_value.empty?

        { endpoint: endpoint, key_name: key_name, key_value: key_value }
      end
    end
  end
end
