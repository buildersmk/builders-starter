# Idempotent seeds. In development, create a single-tenant workspace with an owner so you can sign in
# right away. (In single-tenant mode, signups close once this one account exists.)
if Rails.env.development? && Account.none?
  identity = Identity.find_or_create_by!(email_address: "owner@example.com")
  Account.create_with_owner!(name: "My Workspace", identity: identity, owner_name: "Owner")

  puts "Seeded 'My Workspace' with owner owner@example.com."
  puts "Sign in at /session/new — the 6-digit code is printed to the development log."
end
