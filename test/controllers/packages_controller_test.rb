require "test_helper"

class PackagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get packages_url
    assert_response :success
  end

  test "should get show" do
    get package_url(packages(:one))
    assert_response :success
  end
end
