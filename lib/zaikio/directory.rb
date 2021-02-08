require "faraday"
require "spyke"
require "zaikio/directory/configuration"
require "zaikio/directory/json_parser"
require "zaikio/directory/authorization_middleware"
require "zaikio/directory/basic_auth_middleware"

# Models
require "zaikio/error"
require "zaikio/directory/client"
require "zaikio/directory/base"
require "zaikio/directory/asset"
require "zaikio/directory/organization_membership"
require "zaikio/directory/business_relationship"
require "zaikio/directory/organization"
require "zaikio/directory/person"
require "zaikio/directory/machine"
require "zaikio/directory/software"
require "zaikio/directory/specialist"
require "zaikio/directory/site"
require "zaikio/directory/membership"
require "zaikio/directory/current_person"
require "zaikio/directory/current_organization"
require "zaikio/directory/role"
require "zaikio/directory/revoked_access_token"
require "zaikio/directory/connection"
require "zaikio/directory/subscription"
require "zaikio/directory/test_account"

module Zaikio
  module Directory
    class << self
      attr_accessor :configuration

      class_attribute :connection

      def configure
        self.connection = nil
        self.configuration ||= Configuration.new
        yield(configuration)

        Base.connection = create_connection
      end

      def with_token(token)
        AuthorizationMiddleware.token = token
        yield
      ensure
        AuthorizationMiddleware.reset_token
      end

      def with_basic_auth(login, password)
        BasicAuthMiddleware.credentials = [login, password]
        yield
      ensure
        BasicAuthMiddleware.reset_credentials
      end

      def current_token_data
        return unless AuthorizationMiddleware.token

        payload = JWT.decode(AuthorizationMiddleware.token, nil, false).first

        create_token_data(payload)
      end

      def create_connection
        self.connection = Faraday.new(url: "#{configuration.host}/api/v1",
                                      ssl: { verify: configuration.environment != :test }) do |c|
          c.request     :json
          c.response    :logger, configuration&.logger
          c.use         JSONParser
          c.use         AuthorizationMiddleware
          c.use         BasicAuthMiddleware
          c.adapter     Faraday.default_adapter
        end
      end

      def create_token_data(payload)
        subjects = payload["sub"].split(">")

        OpenStruct.new(
          audience: payload["aud"].first,
          on_behalf_of_id: subjects.first.split("/").last,
          subject_id: subjects.last.split("/").last,
          subject_type: subjects.last.split("/").first,
          scopes: payload["scope"]
        )
      end
    end
  end
end
