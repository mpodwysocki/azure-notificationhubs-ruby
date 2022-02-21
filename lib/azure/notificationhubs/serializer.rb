# frozen_string_literal: true

# Copyright (c) Matthew Podwysocki. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

module Azure
  module NotificationHubs
    # Serializer helper class
    class Serializer
      class << self
        # Convert an object with the transform
        def convert_object(obj, transform)
          data = {}
          obj.instance_variables.each do |ivar|
            key = ivar.to_s.delete("@")
            transformed_key = transform.call(key)
            data[transformed_key] = obj.instance_variable_get(ivar)
          end

          data
        end

        def camel_case_object(obj)
          convert_object(obj, method(:snake_to_camel_case))
        end

        # Convert snake_case to camelCase
        def snake_to_camel_case(key)
          first_word, *rest_words = key.to_s.split("_").reject(&:empty?).map(&:downcase)
          ([first_word] + rest_words.map(&:capitalize)).join
        end

        # Convert camelCase to snake_case
        def camel_to_snake_case(key)
          key.to_s.gsub(/([A-Z])/) { "_#{Regexp.last_match(1)}" }.downcase
        end
      end
    end
  end
end
