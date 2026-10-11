# Seeds. By default we create NOTHING — so the first person to open the app and click "Get started"
# becomes the owner of the single-tenant workspace (signups stay open while there are no accounts).
# That's the natural first run: clone, `bin/dev`, sign up as yourself.
#
# Want a ready-made account to sign in with instead (owner@example.com)? Run:
#   SEED_SAMPLE=1 bin/rails db:seed
if Rails.env.development? && ENV["SEED_SAMPLE"].present? && Account.none?
  identity = Identity.find_or_create_by!(email_address: "owner@example.com")
  Account.create_with_owner!(name: "My Workspace", identity: identity, owner_name: "Owner")

  puts "Seeded 'My Workspace' with owner owner@example.com."
  puts "Sign in at /session/new — the 6-digit code is shown right on the page (development)."
elsif Rails.env.development?
  puts "No seed data (by design). Open the app, click \"Get started\", and the first sign-up becomes the owner."
end
