require "test_helper"

class StudentScehduleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get student_scehdule_index_url
    assert_response :success
  end
end
