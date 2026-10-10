class LoginCodeMailer < ApplicationMailer
  # The passwordless sign-in code. Subject carries the code too, so it's visible from the inbox list.
  def code(identity, code)
    @code = code
    @ttl_minutes = (Identity::LoginCode::LOGIN_CODE_TTL / 60).to_i
    mail(to: identity.email_address, subject: "Your sign-in code: #{code}")
  end
end
