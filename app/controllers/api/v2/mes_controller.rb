class Api::V2::MesController < Api::V2::BaseController
  def show
    render json: as_json(@current_user.as_json(except: %i[password_digest id reset_password_token])), status: :ok
  end

  def update
    if @current_user.update(user_params)
      render json: as_json(@current_user.as_json(except: %i[password_digest id reset_password_token])), status: :ok
    else
      render json: as_json_error(@current_user.errors_details), status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:me).permit(:name, :email, :password, :avatar)
  end
end
