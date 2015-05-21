class DiscountController < ApplicationController
  before_action :authenticate_user!
  before_action :library, :discount, :filtered_books, only: [:index, :take]
  before_action :subscription, only: [:take]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to library_index_path
  end

  def index
    authorize! :read, @discount
    current_user.discount(@discount.code)
  end

  def take
    @subscription.discounting(@discount)
    render 'library/index'
  end

  private
  def discount
    @discount = Discount.find_by_code(params[:code] || params[:coupon])
  end

  def subscription
    @subscription = current_user.subscription
  end
end
