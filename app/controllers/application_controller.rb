class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :tags
  after_action :flash_to_headers

  rescue_from CanCan::AccessDenied do |exception|
    if request.xhr?
      render :json => ['You are not authorised to do that.'], :status => :unauthorized
    else
      redirect_to '/', :alert => exception.message
    end
  end

  rescue_from ActionController::ParameterMissing do
    render :nothing => true, :status => 400
  end

  def after_sign_in_path_for(resource)
    identify
    track_logged_in
    unless params[:redirect_to].nil?
      return params[:redirect_to]
    else
      authenticated_root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    session.delete(:close_info)
    super
  end

  private
  def flash_to_headers
    return unless request.xhr? && !flash.empty?
    response.headers['X-Message'] = URI::encode flash_message
    response.headers["X-Message-Type"] = flash_type.to_s

    flash.discard # don't want the flash to appear when you reload page
  end

  def flash_message
    [:error, :warning, :notice].each do |type|
      return flash[type] unless flash[type].blank?
    end
  end

  def flash_type
    [:error, :warning, :notice].each do |type|
      case type
      when :error
        return :danger unless flash[type].blank?
      when :notice
        return :success unless flash[type].blank?
      else
        return type unless flash[type].blank?
      end
    end
  end

  def books
    @books = Book.all
    if params[:search]
      @books = Book.search_full_text(params[:search])
      if ENV['SEGMENT_IO_KEY']
        Analytics.track(
          user_id: current_user.id,
          event: 'Query',
          properties: {
            keyword: params[:search]
        })
      end
    end
  end

  def library
    @library = current_user.library
  end

  def filtered_books
    @books = @library.librarians.where(state: filter.to_sym).map(&:book)
  end

  def filter
    return 'unread' unless params[:filter]
    params[:filter]
  end

  def tags
    @tags = ActsAsTaggableOn::Tag.all
    @tags = ActsAsTaggableOn::Tag.all.where('LOWER(name) LIKE LOWER(?)', "#{params[:term]}%") if params[:term]
  end

  def identify
    return unless ENV['SEGMENT_IO_KEY']
    Analytics.identify(
      user_id: current_user.id,
      traits: {
        email: current_user.email
      })
  end

  def track_logged_in
    return unless ENV['SEGMENT_IO_KEY']
    Analytics.track(user_id: current_user.id, event: 'Logged in')
  end

  def plans
    @plans = Plan.where.not(name: 'Trial').order(price: :asc)
  end
end
