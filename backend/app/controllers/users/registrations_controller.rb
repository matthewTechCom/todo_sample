module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    private

    def sign_up(resource_name, resource)
      sign_in(resource_name, resource, store: false)
    end

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: {
          user: user_payload(resource),
          token: request.env["warden-jwt_auth.token"]
        }, status: :created
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def user_payload(user)
      { id: user.id, email: user.email }
    end
  end
end
