# Sign-up. Creates the Identity (global login), an Account (the tenant), and the owner User, then
# hands off to the shared 6-digit code step to finish signing in. In single-tenant mode only the first
# visitor can sign up (they become the owner); after that, signups close and people join by invite.
class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  layout "auth"
  rate_limit to: 5, within: 15.minutes, only: :create,
             with: -> { redirect_to new_registration_path, alert: "Too many sign-ups — wait a moment and try again." }

  # GET /signup
  def new
    redirect_to(root_path) and return if authenticated?
    redirect_to new_session_path, alert: "Sign-ups are closed — sign in instead." and return unless Account.accepting_signups?
    @multi_tenant = Account.multi_tenant
  end

  # POST /signup
  def create
    redirect_to(root_path) and return if authenticated?
    redirect_to(new_session_path, alert: "Sign-ups are closed — sign in instead.") and return unless Account.accepting_signups?
    redirect_to(new_registration_path, notice: "Thanks!") and return if params[:company].present? # honeypot

    @name = params[:name].to_s.strip
    @email = params[:email_address].to_s.strip.downcase
    @multi_tenant = Account.multi_tenant

    unless @email.match?(URI::MailTo::EMAIL_REGEXP) && @name.present?
      flash.now[:alert] = "Enter your name and a valid email."
      return render :new, status: :unprocessable_entity
    end

    identity = Identity.find_or_create_by!(email_address: @email)

    if identity.users.exists?
      # Already a member somewhere — just send a sign-in code.
      deliver_login_code(identity)
      session[:login_email] = @email
      return redirect_to new_session_path, status: :see_other,
                         notice: "You already have an account — enter the code we just emailed."
    end

    Account.create_with_owner!(
      name: params[:account_name].to_s.strip.presence || default_account_name(@name),
      identity: identity,
      owner_name: @name,
      subdomain: (@multi_tenant ? params[:subdomain].to_s.strip.presence : nil)
    )

    deliver_login_code(identity)
    session[:login_email] = @email
    redirect_to new_session_path, status: :see_other,
                notice: "Account created — enter the code we emailed to finish signing in."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.first
    render :new, status: :unprocessable_entity
  end

  private
    def default_account_name(name)
      "#{name.split.first}'s workspace"
    end
end
