require "test_helper"

class ExamsSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get exams_schedules_index_url
    assert_response :success
  end

  test "should get create" do
    get exams_schedules_create_url
    assert_response :success
  end

  test "should get update" do
    get exams_schedules_update_url
    assert_response :success
  end

  test "should get destroy" do
    get exams_schedules_destroy_url
    assert_response :success
  end

  test "should get editor" do
    get exams_schedules_editor_url
    assert_response :success
  end
end
