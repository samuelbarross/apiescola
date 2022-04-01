module Api::V1
  class ApiController < ApplicationController
    acts_as_token_authentication_handler_for User, fallback: :none

    protected
    def authenticate_user
      if request.headers['X-Entity-Token'].nil? ||
         request.headers['X-Entity-Email'].nil? ||
         User.where(authentication_token: request.headers['X-Entity-Token'])
             .where(email: request.headers['X-Entity-Email']).count.zero?
        render json: { errors: 'Credenciais inválidas!' }, status: :unauthorized
      else
        @current_user = User.find_by(authentication_token: request.headers['X-Entity-Token'])
      end
    end
  end
end
