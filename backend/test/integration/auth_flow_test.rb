require "test_helper"
require "securerandom"

class AuthFlowTest < ActionDispatch::IntegrationTest
  test "user can sign up, access me, and logout with jwt" do
    email = "signup-#{SecureRandom.hex(4)}@example.com"
    password = "password123"

    post "/auth/signup", params: {
      user: {
        email: email,
        password: password,
        password_confirmation: password
      }
    }, as: :json

    assert_response :created
    assert_equal email, response.parsed_body.dig("user", "email")

    auth_header = response.headers["Authorization"]
    assert_not_nil auth_header
    assert_match(/\ABearer /, auth_header)

    get "/api/v1/me", headers: { "Authorization" => auth_header }, as: :json
    assert_response :success
    assert_equal email, response.parsed_body.dig("user", "email")

    delete "/auth/logout", headers: { "Authorization" => auth_header }, as: :json
    assert_response :no_content

    get "/api/v1/me", headers: { "Authorization" => auth_header }, as: :json
    assert_response :unauthorized
  end

  test "user can login with email and password" do
    password = "password123"
    user = User.create!(
      email: "login-#{SecureRandom.hex(4)}@example.com",
      password: password,
      password_confirmation: password
    )

    post "/auth/login", params: {
      user: {
        email: user.email,
        password: password
      }
    }, as: :json

    assert_response :success
    assert_equal user.email, response.parsed_body.dig("user", "email")
    assert_not_nil response.headers["Authorization"]
  end
end
