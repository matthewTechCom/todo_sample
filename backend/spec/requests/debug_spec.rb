require "rails_helper"
require "securerandom"

RSpec.describe "Debug API", type: :request do
  let!(:user) do
    User.create!(
      email: "debug-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:authorization) do
    post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
    response.headers["Authorization"]
  end

  let(:headers) { { "Authorization" => authorization } }

  after do
    Api::DebugController.reset_leaked_buffers!
  end

  describe "POST /api/debug/db-error" do
    it "returns a database error payload" do
      post "/api/debug/db-error", headers: headers, as: :json

      expect(response).to have_http_status(:internal_server_error)

      body = JSON.parse(response.body)
      expect(body["error"]).to eq("database_error")
      expect(body["details"]).to include("intentionally_missing_debug_table")
    end
  end

  describe "POST /api/debug/timeout" do
    it "sleeps and returns a gateway timeout response" do
      post "/api/debug/timeout", params: { seconds: 0 }, headers: headers, as: :json

      expect(response).to have_http_status(:gateway_timeout)

      body = JSON.parse(response.body)
      expect(body["error"]).to eq("timeout_simulated")
      expect(body["slept_seconds"]).to eq(0)
    end
  end

  describe "POST /api/debug/memory-leak" do
    it "retains memory and returns an internal server error response" do
      post "/api/debug/memory-leak", params: { megabytes: 1 }, headers: headers, as: :json

      expect(response).to have_http_status(:internal_server_error)

      body = JSON.parse(response.body)
      expect(body["error"]).to eq("memory_leak_simulated")
      expect(body["retained_megabytes"]).to eq(1)
    end
  end

  describe "POST /api/debug/500" do
    it "returns an intentional internal server error" do
      post "/api/debug/500", params: { message: "forced failure" }, headers: headers, as: :json

      expect(response).to have_http_status(:internal_server_error)

      body = JSON.parse(response.body)
      expect(body["error"]).to eq("intentional_internal_server_error")
      expect(body["message"]).to eq("forced failure")
    end
  end

  describe "authentication" do
    it "requires a valid bearer token" do
      post "/api/debug/500", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
