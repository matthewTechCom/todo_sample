module Api
  class DebugController < ApplicationController
    before_action :authenticate_user!

    class << self
      def leaked_buffers
        @leaked_buffers ||= []
      end

      def reset_leaked_buffers!
        @leaked_buffers = []
      end
    end

    def db_error
      ActiveRecord::Base.connection.execute("SELECT * FROM intentionally_missing_debug_table")
      head :no_content
    rescue ActiveRecord::StatementInvalid => e
      render_debug_error(
        error: "database_error",
        message: "Intentional invalid SQL triggered a database error.",
        details: e.message
      )
    end

    def timeout
      seconds = bounded_integer_param(:seconds, default: 65, min: 0, max: 300)
      sleep(seconds)

      render json: {
        error: "timeout_simulated",
        message: "Slept long enough to trigger upstream timeout handling.",
        slept_seconds: seconds
      }, status: :gateway_timeout
    end

    def memory_leak
      megabytes = bounded_integer_param(:megabytes, default: 128, min: 1, max: 1024)
      retained = Array.new(megabytes) { "x" * 1.megabyte }

      self.class.leaked_buffers.concat(retained)

      render json: {
        error: "memory_leak_simulated",
        message: "Retained memory in process to simulate a leak and OOM pressure.",
        retained_megabytes: retained_megabytes
      }, status: :internal_server_error
    rescue NoMemoryError => e
      render_debug_error(
        error: "memory_exhausted",
        message: "Memory allocation failed while simulating OOM pressure.",
        details: e.message
      )
    end

    def internal_server_error
      render json: {
        error: "intentional_internal_server_error",
        message: params[:message].presence || "Intentional debug endpoint failure."
      }, status: :internal_server_error
    end

    def n_plus_one
      limit = bounded_integer_param(:limit, default: 25, min: 1, max: 100)
      todos = nil

      query_count = count_sql_queries do
        todos = Todo.where(user_id: current_user.id).order(created_at: :desc).limit(limit).map do |todo|
          {
            id: todo.id,
            title: todo.title,
            completed: todo.completed,
            owner_email: User.uncached { User.find(todo.user_id).email }
          }
        end
      end

      render json: {
        todos: todos,
        meta: {
          todo_count: todos.length,
          query_count: query_count,
          note: "Includes one todo query and one user lookup per todo."
        }
      }, status: :ok
    end

    private

    def render_debug_error(error:, message:, details:)
      render json: {
        error: error,
        message: message,
        details: details
      }, status: :internal_server_error
    end

    def bounded_integer_param(name, default:, min:, max:)
      value = Integer(params[name] || default)
      value.clamp(min, max)
    rescue ArgumentError, TypeError
      default
    end

    def count_sql_queries
      queries = 0

      callback = lambda do |_name, _start, _finish, _id, payload|
        sql = payload[:sql].to_s

        next if payload[:cached]
        next if payload[:name] == "SCHEMA"
        next if sql.match?(/\A(?:BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE SAVEPOINT)/i)

        queries += 1
      end

      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        yield
      end

      queries
    end

    def retained_megabytes
      self.class.leaked_buffers.sum(&:bytesize) / 1.megabyte
    end
  end
end
