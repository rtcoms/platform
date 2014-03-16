class AuthorizationsController < ApplicationController
  skip_before_filter :authenticate_user!

  def all
    ap env["omniauth.auth"]
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

  def linkedin
    client = LinkedIn::Client.new(Rails.configuration.social_config[:linkedin]["app_id"], Rails.configuration.social_config[:linkedin]["app_secret"])
    auth = request.env["omniauth.auth"]
    logger.info "---------------------in linkedin : 1"
    logger.info "http://#{request.host_with_port}/fetch/linkedin"
    logger.info "---------------------in linkedin : 1"
    request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/fetch/linkedin")
    logger.info "----------------------inside linkedin"
    logger.info "rt : #{request_token.inspect}"
    logger.info "----------------------inside linkedin"

    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def fetch_linkedin
    client = LinkedIn::Client.new(Rails.configuration.social_config[:linkedin]["app_id"], Rails.configuration.social_config[:linkedin]["app_secret"])

    pin = params[:oauth_verifier]
    atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)

    session[:pin] = pin
    session[:atoken] = atoken
    session[:asecret] = asecret

    logger.info "-------------------------fetch_linkedin"
    logger.info session[:pin]
    logger.info session[:atoken]
    logger.info session[:asecret]
    logger.info session[:rtoken]
    logger.info session[:rsecret]
    logger.info "--------------------------fetch_linkedin"
    client.authorize_from_access(session[:atoken], session[:asecret])
    #id", "email-address", "first-name", "last-name", "headline", "industry", "picture-url", "public-profile-url", "location", "connections"
    @profile = client.profile(:fields => [:id, :email_address, :headline, :industry,  :first_name, :last_name, :picture_url,:educations, :positions, :public_profile_url, :connections, :location])
    ap @profile
    logger.info @profile
    render :text => @profile.to_yaml
  end


end
