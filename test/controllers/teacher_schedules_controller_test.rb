require "test_helper"

class TeacherSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get teacher_schedules_index_url
    assert_response :success
  end
end
