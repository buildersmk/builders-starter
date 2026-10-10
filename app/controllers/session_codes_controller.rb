# Step 1 of sign-in: take an email and send a 6-digit code. Enumeration-safe — the response is
# identical whether or not the email has an account; we only actually send when it does.
class SessionCodesController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 3.minutes,
             with: -> { redirect_to new_session_path, alert: "Too many requests — wait a moment and try again." }

  # POST /session_code
  def create
    email = params[:email_address].to_s.strip.downcase

    if email.match?(URI::MailTo::EMAIL_REGEXP)
      session[:login_email] = email
      identity = Identity.find_by(email_address: email)
      deliver_login_code(identity) if identity
    end

    redirect_to new_session_path, status: :see_other,
                notice: "If that email has an account, we've sent a 6-digit code — check your inbox."
  end
end
