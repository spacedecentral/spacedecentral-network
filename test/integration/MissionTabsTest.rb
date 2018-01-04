require "test_helper"

class MissionTabsTest < ActionDispatch::IntegrationTest

  test 'view mission tabs' do
    visit('/')
    log_in(users(:user1).email, 'abcdef1!')
    visit('/missions/mars')
    sleep 2
    page.has_xpath?("//div[@id='main_mission_tab']/div[@class='mission_objective']")
    
    find(:xpath, "//a[@href='#mission_files']").click
    sleep 2
    page.has_xpath?("//div[@id='mission_files']/div[@class='mission_file_list_container']")

    find(:xpath, "//a[@href='#mission_crews']").click
    sleep 2
    page.has_xpath?("//div[@id='mission_crews']/div[@class='mission_crews_lists']")

    find(:xpath, "//a[@href='#main_mission_tab']").click
    sleep 2
    page.has_xpath?("//div[@id='main_mission_tab']/div[@class='mission_objective']")
  end

end