require 'rails_helper'

shared_examples "referrable" do
  let(:model) { described_class } # the class that includes the concern

  it "has a referral_code" do
    expect(model.create({ 
      email: 'foo@bar.test', 
      password: '123456'
    }).referral_code).to_not be_nil
  end
end

RSpec.describe User, :type => :model do
  before do
    allow(Plan).to receive(:find_by_name) { Plan.new({active_days: 1}) }
  end

  it_behaves_like "referrable"

  it { should belong_to(:referrer) }
  it { should have_many(:referrals) }
  it { should have_one(:library) }
  it { should have_one(:subscription) }
  it { should accept_nested_attributes_for(:library) }
  it { should validate_uniqueness_of(:referral_code) }
  it { should ensure_inclusion_of(:role).in_array(%w(superuser user)) }
  it { should allow_value('test@kindle.com').for(:kindle) }
  it { should callback(:build_default_library).before(:create) }
  it { should callback(:build_default_subscription).before(:create) }

  describe '#referral' do
    let(:subscription) { Subscription.new(expires_on: Date.today) }

    let(:user) { User.new({ email: 'foo@bar.test', password: '123456', subscription: subscription }) }
    let(:referrer) { User.new({ email: 'referrer@bar.test', password: '123456' }) }

    it 'should upgrade subscription' do
      expect(subscription).to receive(:upgrade_by_referral)
      user.referral(referrer)
    end

    it 'should add referrer user to referrals list' do
      user.referral(referrer)
      expect(user.referrals).to include(referrer)
    end
  end

  describe '#discount' do
    it 'should mark discount_codes as dirty' do
      user = User.new({ 
        email: 'foo@bar.test', 
        password: '123456' 
      })
      expect(user).to receive(:discount_codes_will_change!)
      user.discount('test-code')
    end

    it 'should update the discount_codes attribute' do
      user = User.new({ 
        email: 'foo@bar.test', 
        password: '123456' 
      })
      expect(user).to receive(:update_attributes).with(discount_codes: user.discount_codes.push('test-code'))
      user.discount('test-code')
    end
  end

  describe '#superuser' do
    it 'should returns true' do
      user = User.new({ 
        email: 'foo@bar.test', 
        password: '123456',
        role: 'superuser'
      })
      expect(user.superuser?).to be_truthy
    end

    it 'should returns false' do
      user = User.new({ 
        email: 'foo@bar.test', 
        password: '123456' 
      })
      expect(user.superuser?).to be_falsey
    end
  end

  describe '#add_kindle' do
    let(:subscription) { Subscription.new(expires_on: Date.today) }
    let(:user) { User.new({ email: 'foo@bar.test', password: '123456', subscription: subscription }) }

    it 'should add 1 to kindle sent' do
      expect(subscription).to receive(:update_attribute).with(:kindle, 1)
      user.add_kindle
    end
  end

  describe '#add_pocket' do
    let(:subscription) { Subscription.new(expires_on: Date.today) }
    let(:user) { User.new({ email: 'foo@bar.test', password: '123456', subscription: subscription }) }

    it 'should add 1 to pocket sent' do
      expect(subscription).to receive(:update_attribute).with(:pocket, 1)
      user.add_pocket
    end
  end

  describe '#reset_kindle' do
    let(:subscription) { Subscription.new(expires_on: Date.today, kindle: 2) }
    let(:user) { User.new({ email: 'foo@bar.test', password: '123456', subscription: subscription }) }

    it 'should returns kindle to 0' do
      expect(subscription).to receive(:update_attribute).with(:kindle, 0)
      user.reset_kindle
    end
  end

  describe '#reset_pocket' do
    let(:subscription) { Subscription.new(expires_on: Date.today, pocket: 2) }
    let(:user) { User.new({ email: 'foo@bar.test', password: '123456', subscription: subscription }) }

    it 'should returns pocket to 0' do
      expect(subscription).to receive(:update_attribute).with(:pocket, 0)
      user.reset_pocket
    end
  end
end
