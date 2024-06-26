class AuthenticationController < ApplicationController
  api :POST, "/signup", "Sign up a new user"
  param :name, String, desc: "Name of the user", required: true
  param :email, String, desc: "Email of the user", required: true
  param :password, String, desc: "Password of the user", required: true
  def signup
    user = User.new(user_params)
    if user.save
      render json: { token: JsonWebToken.encode(user_id: user.id) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  api :POST, "/signin", "Sign in an existing user"
  param :email, String, desc: "Email of the user", required: true
  param :password, String, desc: "Password of the user", required: true
  def signin
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      render json: { token: JsonWebToken.encode(user_id: user.id) }, status: :ok
    else
      render json: { errors: ["Invalid email or password"] }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password)
  end
end
