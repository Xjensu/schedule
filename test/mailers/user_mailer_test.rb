require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "sign_in_attempt" do
    mail = UserMailer.sign_in_attempt
    assert_equal "Sign in attempt", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "successful_sign_in" do
    mail = UserMailer.successful_sign_in
    assert_equal "Successful sign in", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
