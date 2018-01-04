require "test_helper"

class RouteTest < ActionDispatch::IntegrationTest

  # test 'landing index' do
    # visit("/")
    # print page.response_headers
    # assert(page.response_headers == 200, "error on page")
  # end

  test 'visit missions index' do
    visit("/missions")
    sleep 2
    # print page.response_headers
    # assert(page.response_headers == 200, "error on page")
  end

  test 'visit mission 1' do
    visit("/missions")
    sleep 2
    # print page.response_headers
    # assert(page.response_headers == 200, "error on page")
  end

  test 'visit users index' do
    visit("/people")
    sleep 2
    # print page.response_headers
    # assert(page.response_headers == 200, "error on page")
  end

  test 'visit user 1 profile' do
    visit("/users/1")
    sleep 2
    # print page.response_headers
    # assert(page.response_headers == 200, "error on page")
  end


  test 'visit forum' do
    visit("/forum")
    sleep 2
    # print page.response_headers
    # assert(page.response_headers == 200, "error on page")
  end

  
end