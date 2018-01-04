class LandingController < ApplicationController
  include LandingHelper
  skip_before_filter :authenticate_user!
  helper_method :resource_name, :resource, :devise_mapping

  def index
    @missions = Mission.mission_type.first(9)
    @projects = Mission.project_type.first(9)
    @trending_posts = Filter::PostFilter.call({ category: Filter::PostFilter::TRENDING }, 1, 6)
  end
end
