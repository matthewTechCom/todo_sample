require "swagger_helper"

RSpec.describe "Auth API", type: :request do
  path "/auth/login" do
    post "Login user and return JWT" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string }
            },
            required: %w[email password]
          }
        },
        required: ["user"]
      }

      response "200", "login success" do
        let!(:user) do
          User.create!(
            email: "rswag-login@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        let(:credentials) { { user: { email: user.email, password: "password123" } } }

        run_test! do |response|
          expect(response.headers["Authorization"]).to start_with("Bearer ")
          body = JSON.parse(response.body)
          expect(body.dig("user", "email")).to eq(user.email)
        end
      end

      response "401", "login failure" do
        let(:credentials) { { user: { email: "unknown@example.com", password: "invalid" } } }

        run_test!
      end
    end
  end
end
