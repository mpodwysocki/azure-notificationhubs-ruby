# frozen_string_literal: true

# Copyright (c) Matthew Podwysocki All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.

require "base64"
require "cgi"
require "openssl"
require "time"

module Azure
  module NotificationHubs
    # This class generates SAS Tokens for accessing Azure Notificaiton Hubs
    class TokenProvider
      def initialize(key_name, key_value)
        @key_name = key_name
        @key_value = key_value
      end

      def generate_signature(url)
        target_uri = CGI.escape(url.downcase).gsub("+", "%20").downcase
        expires = Time.now.utc.to_i + 3600
        to_sign = "#{target_uri}\n#{expires}"

        signature = CGI.escape(
          Base64.strict_encode64(
            OpenSSL::HMAC.digest(
              OpenSSL::Digest.new("SHA256"), @key_value, to_sign
            )
          )
        ).gsub("+", "%20")

        "SharedAccessSignature sr=#{target_uri}&sig=#{signature}&se=#{expires}&skn=#{@key_name}"
      end
    end
  end
end
