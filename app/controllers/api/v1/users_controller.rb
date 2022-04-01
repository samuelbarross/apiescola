class Api::V1::UsersController < Api::V1::ApiController
  before_action :authenticate_user, only: %i[show update destroy]
  before_action :set_user, only: %i[show update destroy]

  def sign_in_user
    user = User.find_for_authentication(login: user_params[:email])
    render json: { errors: 'Email inválido!' }, status: :unauthorized and return unless user

    if user.valid_password?(user_params[:password])
      # render json: sign_in(:user, user)
      render json: { email: user.email , token: user.authentication_token }
    else
      render json: { errors: 'Senha inválida!' }, status: :unauthorized
    end
  end

  def show
    render json: @user, status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    unless @user.update(user_params)
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
  end

  private

  def set_user
    @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: 'Usuário não encontrado!' }, status: :not_found
  end

  def user_params
    params.permit(
      :email, :password, :name, :first_name, :last_name, :sexo, :perfil, :username
    )
  end
end


