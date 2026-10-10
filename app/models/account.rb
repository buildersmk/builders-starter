class Account < ApplicationRecord
  include MultiTenantable, Billable

  has_many :users, dependent: :destroy
  has_many :identities, through: :users

  normalizes :subdomain, with: ->(value) { value.to_s.strip.downcase.presence }

  validates :name, presence: true
  validates :subdomain, uniqueness: true, allow_nil: true,
            format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers and dashes" },
            if: -> { subdomain.present? }

  # Create an account with its first owner in one step — the identity's membership is the owner.
  def self.create_with_owner!(name:, identity:, owner_name:, subdomain: nil)
    transaction do
      account = create!(name: name, subdomain: subdomain)
      account.users.create!(identity: identity, name: owner_name, role: "owner")
      account
    end
  end
end
