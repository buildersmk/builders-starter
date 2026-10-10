class MembershipMailer < ApplicationMailer
  # Sent once when an account goes Pro (Billing#activate!). Swap in your own welcome copy.
  def welcome(user)
    @name = user.name.to_s.split.first.presence || "there"
    mail(to: user.email_address, subject: "You're on Pro — welcome aboard")
  end
end
