class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Too many attempts — wait a moment and try again." }
  layout "auth", only: :new

  # GET /session/new — the email step, or the 6-digit code step once an email is pending.
  # ?reset=1 clears the pending email ("use a different email").
  def new
    redirect_to(root_path) and return if authenticated?
    session.delete(:login_email) if params[:reset]
    @email = session[:login_email]
  end

  # POST /session — verify the code and start a session.
  def create
    identity = Identity.find_by(email_address: session[:login_email]) if session[:login_email].present?

    case identity&.verify_login_code(params[:code])
    when :ok
      session.delete(:login_email)
      start_new_session_for identity
      redirect_to after_authentication_url, status: :see_other
    when :locked, :expired
      redirect_to new_session_path, alert: "That code expired or was locked — send yourself a fresh one.", status: :see_other
    else
      redirect_to new_session_path, alert: "That code isn't right. Try again.", status: :see_other
    end
  end

  # DELETE /session — sign out.
  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end
end
