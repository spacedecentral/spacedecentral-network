require "test_helper"

class AdminPrivTest < ActionDispatch::IntegrationTest

  test 'test create mission' do
    visit('/')
    log_in(users(:admin_user).email, 'abcdef1!')
    visit('/missions')
    page.has_xpath?("//a[@id='create_new_mission_button']")
    click_link('create_new_mission_button')
    sleep 1
    # click_button('Save')
  end

  test 'test edit mission' do
    visit('/')
    log_in(users(:admin_user).email, 'abcdef1!')
    visit('/missions/mars')
    page.has_xpath?("//a[@class='link-edit-mission']")
    click_mission_action_menu
    sleep 0.5
    click_link('Edit Mission')
    sleep 2
  end

end