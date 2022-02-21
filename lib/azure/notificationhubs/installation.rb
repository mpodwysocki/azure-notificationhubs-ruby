# frozen_string_literal: true

# Copyright (c) Matthew Podwysocki. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require_relative "serializer"
require "json"

module Azure
  module NotificationHubs
    # This class represents an installation
    class Installation
      attr_accessor :installation_id, :push_channel, :user_id, :platform, :tags, :templates

      def as_json(_options = {})
        Serializer.camel_case_object(self)
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end

      def self.from_json(source)
        i = Installation.new
        data = JSON.parse(source)
        data.each do |key, value|
          snake_key = Serializer.camel_to_snake_case(key)
          if key.eql? "templates"
            i.templates = ({})
            data[key].each do |k, v|
              i.templates[k] = InstallationTemplate.from_hash(v)
            end
          elsif i.respond_to?(snake_key)
            i.send("#{snake_key}=", value)
          end
        end

        i
      end
    end

    # This class represents an installation template
    class InstallationTemplate
      attr_accessor :body, :headers, :tags

      def as_json(_options = {})
        Serializer.camel_case_object(self)
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end

      def self.from_hash(source)
        i = InstallationTemplate.new
        source.each do |key, value|
          snake_key = Serializer.camel_to_snake_case(key)
          i.send("#{snake_key}=", value) if i.respond_to?(snake_key)
        end
        i
      end
    end

    # This class represents an installation response
    class InstallationResponse
      attr_accessor :location, :correlation_id, :tracking_id
    end
  end
end
