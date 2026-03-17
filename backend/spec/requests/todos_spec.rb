require "swagger_helper"
require "securerandom"

RSpec.describe "Todos API", type: :request do
  path "/api/v1/todos" do
    get "List todos" do
      tags "Todos"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }, required: false

      response "200", "todos fetched" do
        let!(:user) do
          User.create!(
            email: "todos-index-#{SecureRandom.hex(4)}@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end
        let!(:todo) { user.todos.create!(title: "Buy milk") }

        let(:Authorization) do
          post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
          response.headers["Authorization"]
        end

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["todos"].size).to eq(1)
          expect(body["todos"].first["title"]).to eq("Buy milk")
        end
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }

        run_test!
      end
    end

    post "Create todo" do
      tags "Todos"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }, required: false
      parameter name: :todo_params, in: :body, schema: {
        type: :object,
        properties: {
          todo: {
            type: :object,
            properties: {
              title: { type: :string },
              completed: { type: :boolean }
            },
            required: ["title"]
          }
        },
        required: ["todo"]
      }

      response "201", "todo created" do
        let!(:user) do
          User.create!(
            email: "todos-create-#{SecureRandom.hex(4)}@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end
        let(:Authorization) do
          post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
          response.headers["Authorization"]
        end
        let(:todo_params) { { todo: { title: "Write tests", completed: false } } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.dig("todo", "title")).to eq("Write tests")
        end
      end

      response "422", "invalid todo" do
        let!(:user) do
          User.create!(
            email: "todos-create-fail-#{SecureRandom.hex(4)}@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end
        let(:Authorization) do
          post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
          response.headers["Authorization"]
        end
        let(:todo_params) { { todo: { title: "" } } }

        run_test!
      end
    end
  end

  path "/api/v1/todos/{id}" do
    parameter name: :id, in: :path, type: :string

    patch "Update todo" do
      tags "Todos"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }, required: false
      parameter name: :todo_params, in: :body, schema: {
        type: :object,
        properties: {
          todo: {
            type: :object,
            properties: {
              title: { type: :string },
              completed: { type: :boolean }
            }
          }
        },
        required: ["todo"]
      }

      response "200", "todo updated" do
        let!(:user) do
          User.create!(
            email: "todos-update-#{SecureRandom.hex(4)}@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end
        let!(:todo) { user.todos.create!(title: "Initial title") }
        let(:id) { todo.id }
        let(:Authorization) do
          post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
          response.headers["Authorization"]
        end
        let(:todo_params) { { todo: { title: "Updated title", completed: true } } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.dig("todo", "completed")).to eq(true)
        end
      end
    end

    delete "Delete todo" do
      tags "Todos"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }, required: false

      response "204", "todo deleted" do
        let!(:user) do
          User.create!(
            email: "todos-delete-#{SecureRandom.hex(4)}@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end
        let!(:todo) { user.todos.create!(title: "Remove me") }
        let(:id) { todo.id }
        let(:Authorization) do
          post "/api/v1/auth/login", params: { user: { email: user.email, password: "password123" } }, as: :json
          response.headers["Authorization"]
        end

        run_test!
      end
    end
  end
end
