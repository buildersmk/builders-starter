# The Starter Guide — a plain-language, outcome-first how-to for the founder who cloned this kit.
# Development only: the route isn't drawn in production (see config/routes.rb) and this guards again.
class GuideController < ApplicationController
  allow_unauthenticated_access
  layout "marketing"
  before_action :development_only

  def show
    @integrations = StarterGuide.integrations
  end

  private
    def development_only
      head :not_found unless Rails.env.development?
    end
end
