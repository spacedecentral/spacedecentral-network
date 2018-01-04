ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'capybara/rails'
require 'capybara/minitest'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module SignInHelper
  def http_login
    # user = ENV["HTTP_AUTH_USERNAME"]
    # password = ENV["HTTP_AUTH_PASSWORD"]
    # sleep 5
    # if page.driver.respond_to?(:basic_auth)
    #   page.driver.basic_auth(user, password)
    # elsif page.driver.respond_to?(:basic_authorize)
    #   page.driver.basic_authorize(user, password)
    # elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
    #   page.driver.browser.basic_authorize(user, password)
    # elsif page.driver.respond_to?(:headers=) # poltergeist
    #   page.driver.headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
    # else
    #   raise "I don't know how to log in!"
    # end
    # encoded_login = [user+":"+password].pack("m*")
    # page.driver.headers 'Authorization', "Basic #{encoded_login}"
  end

  def log_in(email,password)
    click_link('LOG IN')
    # page.has_xpath?("//form[@id='new_user']")
    within(:css, "form#new_user") do |body|
      fill_in "user[email]", :with=>email
      fill_in "user[password]", :with=>password
    end
    click_on('Log in with email')
  end

  def click_message_nav
    click_link('messages_dropdown_toggle')
  end

  def click_user_nav
    page.find(:css, '.avatar-nav-dropdown .avatar-nav-toggle').click
  end

  def click_mission_action_menu
    click_link('More Actions')
  end
end
 
class ActionDispatch::IntegrationTest
  include SignInHelper

  include Capybara::DSL
  include Capybara::Minitest::Assertions

  setup do
    Capybara.reset_sessions!
    Capybara.current_driver = :selenium
    Capybara.page.driver.browser.manage.window.maximize
  end
  
  def teardown
    Capybara.reset_sessions!
    Capybara.default_driver = :selenium
    Capybara.current_driver = :selenium
  end
end
