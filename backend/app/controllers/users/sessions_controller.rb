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

    def respond_to_on_destroy(_options = {})
      head :no_content
    end

    def user_payload(user)
      { id: user.id, email: user.email }
    end
  end
end
