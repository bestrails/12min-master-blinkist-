class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:promotion]
  before_action :plans, only: [:index]
  before_action :subscription, :plan, :library, :filtered_books, :discount, only: [:update, :pay]

  rescue_from ActiveRecord::RecordNotFound do
    render :nothing => true, :status => 404
  end

  def index
  end

  def update
    upgrade
  end

  def pay
    Iugu.api_key = ENV['IUGU_API_KEY']

    unless params[:token].presence
      raise(ActionController::ParameterMissing.new(params[:token]))
    end

    charge = Iugu::Charge.create({
      token: params[:token],
      email: current_user.email,
      items: [
        {
          description: @plan.name,
          quantity: "1",
          price_cents: price * 1000
        }
      ]
    })

    if charge and charge.success
      token  
      upgrade
      track_subscription_billed
      flash[:notice] = t('subscriptions.pay.success')
    else
      flash[:error] = t('subscriptions.pay.failure')
    end
  end

  def promotion
    discount
    yearly
  end

  private
  def subscription
    @subscription = current_user.subscription
  end

  def plan
    @plan = Plan.find(params[:plan_id]) if params[:plan_id]
  end

  def upgrade
    @subscription.update_attribute(:plan, @plan)
    @subscription.active if @subscription.paused?
  end

  def token
    current_user.update_attribute(:token, params[:token])
  end

  def discount
    @discount = Discount.find_by_code(params[:code] || params[:coupon]) if params[:code] || params[:coupon]
  end

  def yearly
    @yearly = Plan.find_by_name('Yearly')
  end

  def price
    if @discount
      discount = (@plan.price * @discount.percentage) / 100
      return @plan.price - discount
    end
    @plan.price
  end

  def track_subscription_billed
    return unless ENV['SEGMENT_IO_KEY']
    Analytics.track(
      user_id: current_user.id,
      event: 'Subscription billed',
      properties: {
        revenue: number_to_currency(price)
      })
  end
end
