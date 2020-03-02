class LandingController < ApplicationController
  include LandingHelper
  skip_before_action :authenticate_user!
  helper_method :resource_name, :resource, :devise_mapping

  def index
    @featured = Program.where('id in (8, 18, 20, 24, 25)')
#    @programs = Program.program_type.first(9)
    @projects = Program.project_type.first(9)
#    @trending_posts = Filter::PostFilter.call({ category: Filter::PostFilter::TRENDING }, 1, 6)
    @trending_posts = Filter::PostFilter.call({ category: Filter::PostFilter::RECENT }, 1, 3)
  end
end
