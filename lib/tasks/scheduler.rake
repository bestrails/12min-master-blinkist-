desc "This task is called by the Heroku scheduler add-on"
task :expire_subscriptions => :environment do
  Iugu.api_key = ENV['IUGU_API_KEY']

  Subscription.expires.each do |subscription|
    unless subscription.user.nil?
      if !subscription.plan.is_trial? && subscription.user.token.presence
        charge = Iugu::Charge.create({
          token: params[:token],
          email: subscription.user.email,
          items: [
            {
              description: subscription.plan.name,
              quantity: "1",
              price_cents: subscription.plan.price * 1000
            }
          ]
        })
        if charge and charge.success
          if subscription.paused?
            subscription.active
          else
            subscription.update_attribute(:expires_on, (Date.today + subscription.plan.active_days.days))
          end

          if ENV['SEGMENT_IO_KEY']
            Analytics.track(
              user_id: subscription.user.id,
              event: 'Subscription billed',
              properties: {
                revenue: number_to_currency(subscription.plan.price)
              })
          end
        end
      else
        subscription.pause

        if ENV['SEGMENT_IO_KEY']
          Analytics.track(
            user_id: subscription.user.id,
            event: subscription.trial ? 'Trial expired' : 'Subscription expired')
        end
      end
    end
  end
end