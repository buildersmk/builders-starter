# The account's subscription state. Billing (app/services/billing.rb) flips these on Stripe events;
# nothing here talks to Stripe directly. Idle-until-keyed: with no Stripe key, an account simply stays
# on the free plan (or is self-served to pro in dev — see Billing).
module Account::Billable
  extend ActiveSupport::Concern

  def pro?
    plan == Plan::PRO
  end

  def free?
    plan == Plan::FREE
  end

  # Move to the paid plan. Called by Billing on a successful checkout / active subscription.
  def grant_pro!(since: Time.current)
    update!(plan: Plan::PRO, plan_since: since)
  end

  # Back to free — cancellation or a failed/ended subscription.
  def revoke_pro!
    update!(plan: Plan::FREE, plan_since: nil)
  end
end
