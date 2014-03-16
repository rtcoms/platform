class AuthorizationsController < ApplicationController
  skip_before_filter :authenticate_user!

  def all
    p env["omniauth.auth"]
    user = User.from_omniauth(env["omniauth.auth"], current_user)
    if user.persisted?
      flash[:notice] = "You are in..!!! Go to edit profile to see the status for the accounts"
      sign_in_and_redirect(user)
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  alias_method :facebook, :all
  alias_method :linkedin, :all
  alias_method :github, :all
  alias_method :twitter, :all
  alias_method :foursquare, :all

  # def linkedin
  #   client = LinkedIn::Client.new(Rails.configuration.social_config[:linkedin]["app_id"], Rails.configuration.social_config[:linkedin]["app_secret"])
  #   auth = request.env["omniauth.auth"]
  #   logger.info "---------------------in linkedin : 1"
  #   logger.info "http://#{request.host_with_port}/fetch/linkedin"
  #   logger.info "---------------------in linkedin : 1"
  #   request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/fetch/linkedin")
  #   logger.info "----------------------inside linkedin"
  #   logger.info "rt : #{request_token.inspect}"
  #   logger.info "----------------------inside linkedin"

  #   session[:rtoken] = request_token.token
  #   session[:rsecret] = request_token.secret
  #   redirect_to request_token.authorize_url
  # end

end
