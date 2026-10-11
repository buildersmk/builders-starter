# The web app manifest — what makes the app installable ("Add to home screen"). Served from a
# controller (not a static file) so it can use your asset digests and config.
class Pwa::ManifestsController < ApplicationController
  allow_unauthenticated_access
  layout false

  def show
    expires_in 1.hour, public: true
    render formats: :json
  end
end
