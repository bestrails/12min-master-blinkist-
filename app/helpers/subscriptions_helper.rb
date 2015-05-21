module SubscriptionsHelper
  def get_saved_percentage(max_price, selected_price)
    100 - ((selected_price * 100) / max_price).floor
  end

  def get_montly_promotion_price(price, percentage)
    discount = ((price * percentage) / 100).floor
    number_to_currency((price - discount) / 12)
  end

  def get_promotion_price(price, percentage)
    discount = ((price * percentage) / 100).floor
    number_to_currency(price - discount)
  end
end
