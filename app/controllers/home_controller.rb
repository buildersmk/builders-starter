# The public marketing home — the top of the funnel. Anyone can see it.
class HomeController < ApplicationController
  allow_unauthenticated_access
  layout "marketing"

  def show
  end
end
