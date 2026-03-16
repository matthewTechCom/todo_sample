require "swagger_helper"
require "securerandom"

RSpec.describe "Me API", type: :request do
  path "/api/v1/me" do
    get "Get current user" do
      tags "Users"
      produces "application/json"
      security [bearerAuth: []]

      response "200", "current user fetched" do
        let!(:user) do
          User.create!(
            email: "rswag-me-#{SecureRandom.hex(4)}@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        let(:Authorization) do
          post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
          response.headers["Authorization"]
        end

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.dig("user", "email")).to eq(user.email)
        end
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
