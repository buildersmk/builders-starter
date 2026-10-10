# An Account is the tenant — the thing that owns data and (optionally) carries a subscription.
# Single-tenant apps have exactly one; multi-tenant apps (MULTI_TENANT=true) have one per customer,
# resolved by subdomain.
class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :subdomain
      # Billing (Stripe) — all nil/"free" until a subscription activates. See app/models/account/billable.rb.
      t.string :plan, null: false, default: "free"
      t.datetime :plan_since
      t.string :stripe_customer_id

      t.timestamps
    end

    add_index :accounts, :subdomain, unique: true, where: "subdomain IS NOT NULL"
    add_index :accounts, :stripe_customer_id, unique: true, where: "stripe_customer_id IS NOT NULL"
  end
end
