# Single-tenant by default. Set MULTI_TENANT=true to run one account per customer, resolved by
# subdomain (see SetCurrentAccount). Read once at boot.
Rails.application.config.after_initialize do
  Account.multi_tenant = ENV["MULTI_TENANT"] == "true"
end
