# Passwordless sign-in: mint a 6-digit code, email it, verify it. The code is bcrypt-hashed into
# login_code_digest (never stored in the clear), expires after LOGIN_CODE_TTL, throttles resends to
# one per RESEND_INTERVAL, and locks after MAX_ATTEMPTS wrong tries (minting a fresh code resets it).
module Identity::LoginCode
  extend ActiveSupport::Concern

  LOGIN_CODE_TTL  = 15.minutes
  RESEND_INTERVAL = 60.seconds
  MAX_ATTEMPTS    = 5

  def email_confirmed?
    email_confirmed_at.present?
  end

  # Mint a fresh code: store its digest + send time, reset attempts, return the plaintext for the mailer.
  def generate_login_code!
    code = format("%06d", SecureRandom.random_number(1_000_000))
    update!(login_code_digest: BCrypt::Password.create(code), login_code_sent_at: Time.current, login_code_attempts: 0)
    code
  end

  def login_code_recently_sent?
    login_code_sent_at.present? && login_code_sent_at > RESEND_INTERVAL.ago
  end

  # Returns :ok | :invalid | :locked | :expired. On :ok the code is one-time-consumed.
  def verify_login_code(code)
    return :expired if login_code_digest.blank? || login_code_sent_at.blank?
    return :expired if login_code_sent_at < LOGIN_CODE_TTL.ago
    return :locked if login_code_attempts >= MAX_ATTEMPTS

    if BCrypt::Password.new(login_code_digest).is_password?(code.to_s.strip)
      update!(email_confirmed_at: email_confirmed_at || Time.current, login_code_digest: nil, login_code_attempts: 0)
      :ok
    else
      increment!(:login_code_attempts)
      login_code_attempts >= MAX_ATTEMPTS ? :locked : :invalid
    end
  end
end
