class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    track_signed_up
    books_path
  end

  def track_signed_up
    return unless ENV['SEGMENT_IO_KEY']
    Analytics.track(anonymous_id: resource.email, event: 'Signed Up')
  end
end