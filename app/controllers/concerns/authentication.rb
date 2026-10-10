# Session-cookie authentication over the passwordless Identity + Session models. Every controller
# requires a signed-in user by default; opt out per-action with `allow_unauthenticated_access`.
# Based on the Rails 8 generated authentication concern, adapted for Identity-based sessions.
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user, :current_account
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end

    # Guard an action (or controller) behind an admin/owner role in the current account.
    def require_admin(**options)
      before_action :require_admin_access, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def current_user
      Current.user
    end

    def current_account
      Current.account
    end

    def require_authentication
      resume_session || request_authentication
    end

    def require_admin_access
      redirect_to root_path, alert: "You don't have access to that." unless Current.user&.admin?
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(identity)
      identity.sessions.create!(user_agent: Current.user_agent, ip_address: Current.ip_address).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_id)
    end

    # Mint + email a 6-digit code. In development the code is also written to the log so you don't
    # need a mail catcher.
    def deliver_login_code(identity)
      code = identity.generate_login_code!
      Rails.logger.info("[login-code] #{identity.email_address}: #{code}") if Rails.env.development?
      LoginCodeMailer.code(identity, code).deliver_later
    end
end
