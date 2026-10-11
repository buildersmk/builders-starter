# One browser/device that opted into web push. Created by PushSubscriptionsController when someone
# taps "enable notifications"; used by Push to deliver. `gave_up_at` marks a dead endpoint.
class PushSubscription < ApplicationRecord
  belongs_to :identity, optional: true

  scope :live, -> { where(gave_up_at: nil) }

  def gave_up!
    update_column(:gave_up_at, Time.current)
  end
end
