require 'rails_helper'

RSpec.describe DiscountHelper, :type => :helper do
  describe '#yearly_price' do
    let(:discount) { double('discount', percentage: 10) }
    let(:plan) { double('plan', price: 10) }

    before do
      allow(discount).to receive(:plan) { plan }
    end

    it 'should get plan price for 12 month with discount' do
      price_with_discount = (10*10)/100
      expect(yearly_price(discount)).to eq((discount.plan.price * 12) - (price_with_discount * 12))
    end
  end
end
