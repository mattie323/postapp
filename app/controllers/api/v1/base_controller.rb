class Api::V1::BaseController < ApplicationController
  include Pagy::Backend

  def pagy_metadata(pagy)
    {
      count: pagy.count,
      pages: pagy.pages,
      from:  pagy.from,
      to:    pagy.to,
      prev:  pagy.prev,
      next:  pagy.next,
      page:  pagy.page,
      items: pagy.items,
      last:  pagy.last
    }
  end

  def authorize_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    decoded = JsonWebToken.decode(header)
    @current_user = User.find(decoded[:user_id]) if decoded
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: ["Unauthorized"] }, status: :unauthorized
  end
end
