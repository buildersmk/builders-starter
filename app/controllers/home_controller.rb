# The public marketing home — the top of the funnel. Anyone can see it.
# In development, the home doubles as the first-run welcome: `show` renders the Starter Guide
# welcome + checklist instead of the marketing page, so a founder opening the app for the first
# time knows exactly what to do next. In production it's always the marketing page.
class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "marketing"

  def show
    render :welcome if Rails.env.development?
  end

  # GET /preview (development only) — the marketing page you'll customize, so you can see what
  # ships to customers while the welcome screen is your home.
  def marketing
    render :marketing
  end
end
