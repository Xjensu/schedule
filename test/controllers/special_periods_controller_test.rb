require "test_helper"

class SpecialPeriodsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get special_periods_index_url
    assert_response :success
  end

  test "should get new" do
    get special_periods_new_url
    assert_response :success
  end

  test "should get create" do
    get special_periods_create_url
    assert_response :success
  end

  test "should get edit" do
    get special_periods_edit_url
    assert_response :success
  end

  test "should get update" do
    get special_periods_update_url
    assert_response :success
  end

  test "should get destroy" do
    get special_periods_destroy_url
    assert_response :success
  end
end
