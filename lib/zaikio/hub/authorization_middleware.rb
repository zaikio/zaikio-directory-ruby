require "faraday"
require "jwt"
require "concurrent"

module Zaikio
  module Hub
    class AuthorizationMiddleware < Faraday::Middleware
      def self.token
        @token ||= Concurrent::ThreadLocalVar.new { nil }
        @token.value
      end

      def self.token=(value)
        @token ||= Concurrent::ThreadLocalVar.new { nil }
        @token.value = value
      end

      def self.reset_token
        self.token = nil
      end

      def call(request_env)
        if self.class.token
          request_env[:request_headers]["Authorization"] = "Bearer #{self.class.token}"
        end

        @app.call(request_env).on_complete do |response_env|
        end
      end
    end
  end
end
