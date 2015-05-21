require 'rails_helper'

RSpec.describe Subscription, :type => :model do
  it { should belong_to(:plan) }
  it { should belong_to(:user) }
  it { should belong_to(:discount) }
  it { should validate_presence_of(:expires_on) }

  context '#state' do
    describe 'transitions' do
      let(:from_actived_to_paused) do
        OpenStruct.new({
          :state_field => :state,
          :name => :pause,
          :from => :actived,
          :to => :paused
        })
      end

      let(:from_paused_to_actived) do
        OpenStruct.new({
          :state_field => :state,
          :name => :active,
          :from => :paused,
          :to => :actived
        })
      end

      it { should be_actived } # check initial state
      it { should have_transition from_actived_to_paused }
      it { should have_transition from_paused_to_actived }
    end

    describe 'after_transition' do
      context '#active' do
        it 'should update the expires_on' do
          plan = Plan.new(name: 'Test', active_days: 5)
          subscription = Subscription.new(expires_on: Date.today - 1.month, state: :paused, plan: plan)
          subscription.active
          expect(subscription.expires_on).to eq(Date.today + 5.days)
        end
      end
    end
  end

  describe '#upgrade_by_referral' do
    it 'should sum 7 days to expires_on' do
      subscription = Subscription.new(expires_on: Date.today)
      subscription.upgrade_by_referral
      expect(subscription.expires_on).to eq(Date.today + 7.days)
    end
  end

  describe '#discounting' do
    it 'should assign discount' do
      subscription = Subscription.new(expires_on: Date.today)
      discount = Discount.new(code: 'test')
      subscription.discounting(discount)
      expect(subscription.discount).to be(discount)
    end
  end
end
