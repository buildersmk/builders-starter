# The marketing lead-capture endpoint — email in, Kit tag out (best-effort, no-ops without a key).
class LeadsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, with: -> { redirect_to root_path, alert: "Too many requests — try again shortly." }

  def create
    email = params[:email].to_s.strip.downcase

    if email.match?(URI::MailTo::EMAIL_REGEXP)
      KitTagger.tag(email: email)
      redirect_to root_path, notice: "You're on the list — thanks!"
    else
      redirect_to root_path, alert: "Enter a valid email."
    end
  end
end
