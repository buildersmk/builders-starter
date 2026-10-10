class ApplicationController < ActionController::Base
  # Order matters: request details, then resolve the account (tenant), then authenticate — so the
  # current user (identity × account) can be resolved. Every action requires a signed-in user unless
  # it opts out with `allow_unauthenticated_access`.
  include SetCurrentRequest
  include SetCurrentAccount
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
