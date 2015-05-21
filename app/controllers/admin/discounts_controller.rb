class Admin::DiscountsController < Admin::SuperusersController
  before_action :discounts, only: [:index]
  before_action :discounts, only: [:edit, :update, :destroy]
  before_action :create_discount, only: [:create]

  load_and_authorize_resource
  
  def index
  end

  def new
  end

  def create
    if @discount.save
      discounts && flash[:notice] = t('discount.create.success')
    else
      flash[:error] = t('discount.create.failure')
    end
  end

  def edit
  end

  def update
    if @discount.update_attributes(discount_params)
      discounts && flash[:notice] = t('discount.update.success')
    else
      flash[:error] = t('discount.update.failure')
    end
  end

  def destroy
    if @discount.destroy
      discounts && flash[:notice] = t('discount.destroy.success')
    else
      flash[:error] = t('discount.destroy.failure')
    end
  end

  private
  def discounts
    @discounts = Discount.all
  end

  def discount
    @discount = Discount.find(params[:id])
  end

  def create_discount
    @discount = Discount.new(discount_params)
  end

  def discount_params
    params.require(:discount).permit(:code, :percentage)
  end
end
