module DiscountHelper
  def yearly_price(discount)
    difference_price = (discount.plan.price * discount.percentage) / 100
    (discount.plan.price * 12) - (difference_price * 12)
  end
end
