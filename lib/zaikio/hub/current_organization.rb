module Zaikio
  module Hub
    class CurrentOrganization < Base
      self.primary_key = nil

      uri "organization"

      def self.find
        all.find_one
      end

      def self.find_with_fallback(fallback)
        all.with_fallback(fallback).find_one
      end

      include_root_in_json :organization

      # Attributes
      attributes :id, :name, :slug, :logo_url, :connected, :subscription,
                 :created_at, :updated_at, :country_code, :kinds,
                 :sections, :currency, :brand_color, :test_account_owner_id,
                 :granted_oauth_scopes, :requested_oauth_scopes,
                 :requested_oauth_scopes_waiting_for_approval

      # Associations
      has_many :memberships,             class_name: "Zaikio::Hub::Membership",
                                         uri: "organization/memberships(/:id)"
      has_many :business_relationships,  class_name: "Zaikio::Hub::BusinessRelationship",
                                         uri: "organization/business_relationships(/:id)"
      has_many :software,                class_name: "Zaikio::Hub::Software",
                                         uri: "software(/:id)"
      has_many :machines,                class_name: "Zaikio::Hub::Machine",
                                         uri: "machines(/:id)"
      has_many :specialists,             class_name: "Zaikio::Hub::Specialist",
                                         uri: "specialists(/:id)"
      has_many :sites,                   class_name: "Zaikio::Hub::Site",
                                         uri: "sites(/:id)"

      def fetch
        self.attributes = get
      end

      def reload
        self.attributes = self.class.find.attributes
      end

      def members
        memberships.with_fallback.map(&:person)
      end
    end
  end
end
