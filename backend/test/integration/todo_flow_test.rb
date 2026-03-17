require "test_helper"
require "securerandom"

class TodoFlowTest < ActionDispatch::IntegrationTest
  test "user can create, update, list, and delete todos" do
    password = "password123"
    user = User.create!(
      email: "todo-flow-#{SecureRandom.hex(4)}@example.com",
      password: password,
      password_confirmation: password
    )

    post "/api/v1/auth/login", params: { user: { email: user.email, password: password } }, as: :json
    auth_header = response.headers["Authorization"]

    post "/api/v1/todos", params: { todo: { title: "First todo" } }, headers: { "Authorization" => auth_header }, as: :json
    assert_response :created
    todo_id = response.parsed_body.dig("todo", "id")

    get "/api/v1/todos", headers: { "Authorization" => auth_header }, as: :json
    assert_response :success
    assert_equal 1, response.parsed_body["todos"].size

    patch "/api/v1/todos/#{todo_id}", params: { todo: { completed: true, title: "Done todo" } }, headers: { "Authorization" => auth_header }, as: :json
    assert_response :success
    assert_equal true, response.parsed_body.dig("todo", "completed")

    delete "/api/v1/todos/#{todo_id}", headers: { "Authorization" => auth_header }, as: :json
    assert_response :no_content

    get "/api/v1/todos", headers: { "Authorization" => auth_header }, as: :json
    assert_response :success
    assert_equal [], response.parsed_body["todos"]
  end
end
