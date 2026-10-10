# Single-tenant by default; flip MULTI_TENANT=true to run one account per customer (resolved by
# subdomain — see SetCurrentAccount). The toggle is read once at boot (config/initializers/multi_tenant.rb).
module Account::MultiTenantable
  extend ActiveSupport::Concern

  included do
    cattr_accessor :multi_tenant, default: false
  end

  class_methods do
    # Single-tenant: accept a signup only until the one account exists (the first visitor becomes the
    # owner, then signups close). Multi-tenant: always open — every signup creates a new account.
    def accepting_signups?
      multi_tenant || Account.none?
    end
  end
end
