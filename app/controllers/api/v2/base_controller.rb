class Api::V2::BaseController < ActionController::API
  before_action :authorized
  # wrap_parameters true
  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: as_json_error(message: exception.message), status: :not_found
  end

  rescue_from ForbiddenError do |exception|
    render json: as_json_error(message: exception.message), status: :forbidden
  end

  rescue_from ActionController::ParameterMissing do |exception|
    puts params
    puts exception
    render json: as_json_error(message: exception.message), status: :bad_request
  end

  rescue_from JWT::ExpiredSignature do |exception|
    render(json: as_json_error(message: 'Token has expired'), status: :unauthorized)
  end

  rescue_from JWT::DecodeError do |exception|
    render json: as_json_error(message: 'Please log in'), status: :unauthorized
  end

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      JWT.decode(token, ENV['JWT_SECRET'], true, algorithm: 'HS256')
    end
  end

  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @current_user ||= User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: as_json_error(message: 'Please log in'), status: :unauthorized unless logged_in?
  end

  def as_json_list records, pagy = nil
    {
      data: {
        items: records,
      },
      pagination: pagy ? pagy_meta(pagy) : {}
    }
  end

  def as_json data
    { data: data }
  end

  def as_json_error errors_details = [], message: 'Validation failed'
    {
      type: :validation,
      status: :bad_request,
      path: '',
      message: message,
      error_code: :bad_request,
      errors: errors_details
    }
  end

  private
  def pagy_meta(pagy)
    data = pagy_metadata(@pagy)
    {
      count: data[:count],
      page: data[:page],
      offset: data[:items],
      total: data[:pages],
      prev: data[:prev],
      next: data[:next]
    }
  end
end
