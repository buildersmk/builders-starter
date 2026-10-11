# The service worker. Served from the site root (not under /pwa/) so its scope can control every
# page, with no-store so a new worker is picked up immediately on deploy. Forgery protection is
# off because the browser fetches a worker with no session/referer.
class Pwa::ServiceWorkersController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection
  layout false

  def show
    response.headers["Cache-Control"] = "no-store"
    render formats: :js, content_type: "text/javascript"
  end
end
