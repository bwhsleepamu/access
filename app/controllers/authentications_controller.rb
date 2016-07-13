
# frozen_string_literal: true

class AuthenticationsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :destroy]

  skip_before_action :verify_authenticity_token, only: [:create, :failure, :passthru]


  def index
  end

  def passthru
    render file: "#{Rails.root}/public/404", formats: [:html], status: 404, layout: false
  end

  def failure
    redirect_to new_user_session_path, alert: params[:message].blank? ? nil : params[:message].humanize
  end


  def create
    if auth_hash
      authentication = Authentication.find_by_provider_and_uid(auth_hash[:provider], auth_hash[:uid])
      auth_hash['info']['email'] = auth_hash['extra']['raw_info']['email'] if auth_hash['info'] and auth_hash['info']['email'].blank? and auth_hash['extra'] and auth_hash['extra']['raw_info']

      if authentication
        logger.info "Existing authentication found."
        flash[:notice] = "Signed in successfully." if authentication.user.active_for_authentication?
        sign_in_and_redirect(:user, authentication.user)
      elsif current_user
        logger.info "Logged in user found, creating associated authentication."
        current_user.authentications.create!( provider: omniauth['provider'], uid: omniauth['uid'] )
        redirect_to authentications_path, notice: "Authentication successful."
      else
        logger.info "Creating new user with new authentication."
        user = User.new(params[:user])
        user.apply_omniauth(auth_hash)
        user.password = Devise.friendly_token[0,20] if user.password.blank?
        if user.save
          flash[:notice] = "Signed in successfully." if user.active_for_authentication?
          sign_in_and_redirect(:user, user)
        else
          session[:omniauth] = auth_hash.except('extra')
          redirect_to new_user_registration_path
        end
      end
    else
      redirect_to authentications_path, alert: 'Authentication not successful.'
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    respond_to do |format|
      format.html { redirect_to authentications_path, notice: 'Successfully removed authentication.' }
      format.js
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end