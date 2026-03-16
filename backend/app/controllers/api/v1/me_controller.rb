module Api
  module V1
    class MeController < ApplicationController
      before_action :authenticate_user!

      def show
        render json: { user: { id: current_user.id, email: current_user.email } }, status: :ok
      end
    end
  end
end
