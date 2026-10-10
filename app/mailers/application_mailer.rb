class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "Builders Starter <onboarding@example.com>")
  layout "mailer"
end
