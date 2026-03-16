require "swagger_helper"
require "securerandom"

RSpec.describe "Auth API", type: :request do
  path "/api/v1/auth/signup" do
    post "Sign up user and return JWT" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :signup_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: %w[email password password_confirmation]
          }
        },
        required: ["user"]
      }

      response "201", "signup success" do
        let(:email) { "rswag-signup-#{SecureRandom.hex(4)}@example.com" }
        let(:signup_params) do
          {
            user: {
              email: email,
              password: "password123",
              password_confirmation: "password123"
            }
          }
        end

        run_test! do |response|
          expect(response.headers["Authorization"]).to start_with("Bearer ")
          body = JSON.parse(response.body)
          expect(body.dig("user", "email")).to eq(email)
        end
      end

      response "422", "signup failure" do
        let(:signup_params) { { user: { email: "invalid", password: "123", password_confirmation: "123" } } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/login" do
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

  path "/api/v1/auth/logout" do
    delete "Logout user" do
      tags "Auth"
      produces "application/json"
      security [bearerAuth: []]

      response "204", "logout success" do
        let!(:user) do
          User.create!(
            email: "rswag-logout-#{SecureRandom.hex(4)}@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        let(:Authorization) do
          post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
          response.headers["Authorization"]
        end

        run_test!
      end
    end
  end
end
