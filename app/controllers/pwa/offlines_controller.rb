# The offline fallback page. Precached by the service worker and shown when a navigation fails
# with no network. Self-contained so it renders from cache.
class Pwa::OfflinesController < ApplicationController
  allow_unauthenticated_access
  layout false

  def show
  end
end
