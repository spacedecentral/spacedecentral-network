require "test_helper"

class MessageTest < ActionDispatch::IntegrationTest

  test 'send message' do
    visit('/')
    log_in(users(:user1).email, 'abcdef1!')
    visit('/users/2')
    sleep 1
    click_link('profile_message_button')
    sleep 1
    assert(page.has_xpath?("//textarea[@id='message_body']"), "did not find message textarea")
    sleep 1
    within(:css, "form#message_form") do |body|
      fill_in "message_body", :with=>"goopda oopda roheeny"
    end
    click_on('Send Message')
    sleep 5

    click_message_nav    
    sleep 2
    msg = page.find(:css, "#nav_messages_list")['innerHTML']
    # print msg
    assert(msg.include?("goopda oopda roheeny"), "message not in user 1's nav")

    sleep 1
    find("//div[@id='nav_messages_list']/div[@class='message-text']/a").click
    sleep 1

    click_user_nav
    click_link('nav_logout_link')

    # log_in(users(:user2).email, 'abcdef1!')
    # visit('/users/1')
    # click_link('messages_dropdown_toggle')
    # msg = page.find(:css, "#nav_messages_list")['innerHTML']
    # # print msg
    # assert(msg.include?("goopda oopda roheeny"), "message not in user 1's nav")

    # click_user_nav
    # click_link('nav_logout_link')
  end
  
end