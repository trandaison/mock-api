class Api::V2::Admin::UsersController < Api::V2::Admin::BaseController
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @q = User.order(created_at: :desc).ransack(search_query)
    @pagy, @users = pagy(@q.result, items: params[:offset])

    render json: as_json_list(@users.as_json(except: %i[password_digest reset_password_token]), @pagy)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: as_json(@user.reload.as_json(except: %i[password_digest reset_password_token])), status: :created
    else
      render json: as_json_error(@user.errors_details), status: :unprocessable_entity
    end
  end

  def show
    render json: as_json(@user.as_json(except: %i[password_digest reset_password_token]))
  end

  def update
    if @user.update(user_params)
      render json: as_json(@user.reload.as_json(except: %i[password_digest reset_password_token]))
    else
      render json: as_json_error(@user.errors_details), status: :unprocessable_entity
    end
  end

  def destroy
    raise ForbiddenError if @user.id == current_user.id

    @user.destroy
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def search_query
    {
      name_or_email_cont: params[:search],
      s: "#{params[:sort_by]} #{params[:sort_direction]}"
    }
  end

  def user_params
    params.permit(:email, :password, :name, :avatar, :admin)
  end
end
