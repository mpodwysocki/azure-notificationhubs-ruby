# frozen_string_literal: true

# Copyright (c) Matthew Podwysocki. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require_relative "errors"
require_relative "notification"
require_relative "serializer"
require_relative "token_provider"
require "uri"
require "net/http"
require "json"

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

      def delete_installation(installation_id)
        fixed_host = @base_uri.gsub("sb://", "https://")
        target_uri = "#{fixed_host}#{@hub_name}/installations/#{installation_id}?api-version=#{API_VERSION}"

        endpoint_uri = URI(target_uri)
        https = Net::HTTP.new(endpoint_uri.host, endpoint_uri.port)
        https.use_ssl = true
        request = Net::HTTP::Delete.new(endpoint_uri.path, "Content-Type" => "application/json")

        request["Authorization"] = @token_provider.generate_signature(@base_uri)

        response = https.request(request)

        # TODO: Add retry logic
        raise HttpError.new(response.code, response.msg) unless response.code == "204"

        tracking_id = response["TrackingId"]
        location = response["Location"]
        correlation_id = response["x-ms-correlation-request-id"]

        InstallationResponse.new(location, tracking_id, correlation_id)
      end

      def get_installation(installation_id)
        fixed_host = @base_uri.gsub("sb://", "https://")
        target_uri = "#{fixed_host}#{@hub_name}/installations/#{installation_id}?api-version=#{API_VERSION}"

        endpoint_uri = URI(target_uri)
        https = Net::HTTP.new(endpoint_uri.host, endpoint_uri.port)
        https.use_ssl = true
        request = Net::HTTP::Get.new(endpoint_uri.path, "Content-Type" => "application/json")

        request["Authorization"] = @token_provider.generate_signature(@base_uri)

        response = https.request(request)

        # TODO: Add retry logic
        raise HttpError.new(response.code, response.msg) unless response.code == "200"

        json_data = response.body

        Installation.from_json json_data
      end

      def patch_installation(installation_id, patches)
        fixed_host = @base_uri.gsub("sb://", "https://")
        target_uri = "#{fixed_host}#{@hub_name}/installations/#{installation_id}?api-version=#{API_VERSION}"

        endpoint_uri = URI(target_uri)
        https = Net::HTTP.new(endpoint_uri.host, endpoint_uri.port)
        https.use_ssl = true
        request = Net::HTTP::Patch.new(endpoint_uri.path, "Content-Type" => "application/json")

        request["Authorization"] = @token_provider.generate_signature(@base_uri)

        request.body = patches.to_json

        response = https.request(request)

        # TODO: Add retry logic
        raise HttpError.new(response.code, response.msg) unless response.code == "201"

        tracking_id = response["TrackingId"]
        location = response["Location"]
        correlation_id = response["x-ms-correlation-request-id"]

        InstallationResponse.new(location, tracking_id, correlation_id)
      end

      def upsert_installation(installation)
        fixed_host = @base_uri.gsub("sb://", "https://")
        target_uri = "#{fixed_host}#{@hub_name}/installations/#{installation.installation_id}?api-version=#{API_VERSION}"

        endpoint_uri = URI(target_uri)
        https = Net::HTTP.new(endpoint_uri.host, endpoint_uri.port)
        https.use_ssl = true
        request = Net::HTTP::Patch.new(endpoint_uri.path, "Content-Type" => "application/json")

        request["Authorization"] = @token_provider.generate_signature(@base_uri)

        json_data = Serializer.came_case_object(installation)
        json_templates = json_data["templates"]
        json_data["templates"] = json_templates.to_json unless json_templates.nil?

        request.body = json_data

        raise HttpError.new(response.code, response.msg) unless response.code == "201"

        tracking_id = response["TrackingId"]
        location = response["Location"]
        correlation_id = response["x-ms-correlation-request-id"]

        InstallationResponse.new(location, tracking_id, correlation_id)
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
