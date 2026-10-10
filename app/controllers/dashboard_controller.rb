# The authenticated app home. Requires a signed-in user with a membership in the current account.
class DashboardController < ApplicationController
  before_action :require_membership

  def show
  end

  private
    def require_membership
      redirect_to root_path, alert: "No workspace found for your account." unless Current.user
    end
end
