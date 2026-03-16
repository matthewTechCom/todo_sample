module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: {
        user: user_payload(resource),
        token: request.env["warden-jwt_auth.token"]
      }, status: :ok
    end

    def respond_to_on_destroy(options = {})
      head options.fetch(:non_navigational_status, :no_content)
    end

    def all_signed_out?
      return jwt_user.blank? if request.authorization.present?

      super
    end

    def user_payload(user)
      { id: user.id, email: user.email }
    end

    def jwt_user
      @jwt_user ||= warden.authenticate(scope: resource_name)
    rescue JWT::DecodeError, JWT::VerificationError
      nil
    end
  end
end
