class HighVoltage::PagesController < ApplicationController
  skip_before_action :authenticate_user!

  include HighVoltage::StaticPage
end
