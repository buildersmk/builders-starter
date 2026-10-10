# Resolves the tenant for this request into Current.account. Single-tenant: the one and only account.
# Multi-tenant (MULTI_TENANT=true): the account whose subdomain matches the request (nil on the apex /
# www host — e.g. the marketing site).
module SetCurrentAccount
  extend ActiveSupport::Concern

  included do
    before_action :set_current_account
  end

  private
    def set_current_account
      Current.account = resolve_account
    end

    def resolve_account
      if Account.multi_tenant
        subdomain = request.subdomain.presence
        subdomain && subdomain != "www" ? Account.find_by(subdomain: subdomain) : nil
      else
        Account.first
      end
    end
end
