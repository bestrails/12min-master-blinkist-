class Users::InvitationsController < Devise::InvitationsController
  before_action :mixpanel

  def new
  end

  def create
    params[:referring][:emails].split(",").each do |email|
      resource_class.invite!({ :email => email }, current_inviter)

      track(current_inviter.email, 'invite sent')
      track(email, 'invited')
    end

    flash[:notice] = t('devise.invitations.send_bulk_instructions')
  end

  def edit
    @referral_code = params[:referral_code]
    
    track(user.email, 'invitee rendered')
    track(self.resource.email, 'invite rendered')

    track(user.email, 'invitee reg.page')
    track(self.resource.email, 'registration loaded', { :from_invite => true })

    super
  end

  def update
    self.resource = accept_resource

    track(user.email, 'invitee reg.submit')
    track(self.resource.email, 'reg. form submitted')

    if resource.errors.empty?
      yield resource if block_given?
      
      if resource.active_for_authentication?
        track(user.email, 'invitee conversion')
        track(self.resource.email, 'conversion')

        flash_message = :updated
        referral
        UsersMailer.accepted_invite(user).deliver
      else
        flash_message = :updated_not_active                                                                                        
      end

      set_flash_message :notice, flash_message
      sign_in(resource_name, resource)
      respond_with resource, :location => after_accept_path_for(resource)
    else
      respond_with_navigational(resource){ render :edit }
    end
  end

  private
  def referral
    if user
      user.referral(resource)
    end
  end

  def user
    return User.find_by_referral_code(@referral_code) if @referral_code
    if params[:inviter][:referral_code]
      user = User.find_by_referral_code(params[:inviter][:referral_code])
    end
  end

  def mixpanel
    @mixpanel ||= Mixpanel::Tracker.new ENV['MIXPANEL_TOKEN'] if ENV['MIXPANEL_TOKEN']
  end

  def track(distinct_id, event, properties={})
    if @mixpanel
      @mixpanel.track(distinct_id, event, properties)
    end
  end
end