require 'rails_helper'

RSpec.describe SubscriptionsHelper, :type => :helper do
  describe '#get_montly_promotion_price' do
    it { expect(get_montly_promotion_price(120, 10)).to eq(number_to_currency(9)) }
    it { expect(get_promotion_price(100, 10)).to eq(number_to_currency(90)) }
  end
end
