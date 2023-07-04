class Api::V2::Admin::BaseController < Api::V2::BaseController
  before_action :admin_only

  private

  def admin_only
    raise ForbiddenError unless current_user&.admin?
  end
end
