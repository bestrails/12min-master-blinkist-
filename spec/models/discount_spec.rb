require 'rails_helper'

RSpec.describe Discount, :type => :model do
  it { should belong_to(:plan) }
  it { should have_many(:subscriptions) }
  it { should validate_uniqueness_of(:code) }

  describe '#is_valid?' do
    let(:discount) { Discount.create({code: 'Test', days_to_expire: 10 }) }

    context 'when created_at + days_to_expire is greater than Date.today' do
      it { expect(discount.is_valid?).to be true }
    end

    context 'when created_at + days_to_expire is less than Date.today' do
      before do 
        future_day = (Date.today + 12.days)
        allow(Date).to receive(:today) { future_day }
      end

      it { expect(discount.is_valid?).to be false }
    end
  end
end
