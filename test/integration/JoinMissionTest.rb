require "test_helper"

class JoinMissionTest < ActionDispatch::IntegrationTest

  test 'join mars mission' do
    visit('/')
    log_in(users(:user1).email, 'abcdef1!')
    visit('/missions/mars')
    page.has_xpath?("//a[@id='join_mission_button']")
    click_link('join_mission_button')
    page.has_xpath?("//div[@class='join_mission_form']/input[@name='mission_id']")
    click_on('Join')
    sleep 2
    page.has_xpath?("//a[@title='Unfollow Mars']")
    sleep 2
  end

end