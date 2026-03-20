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

    def retained_megabytes
      self.class.leaked_buffers.sum(&:bytesize) / 1.megabyte
    end
  end
end
