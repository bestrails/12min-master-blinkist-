require 'rails_helper'

RSpec.describe Plan, :type => :model do
  it { should have_many(:subscriptions) }
  it { should have_many(:discounts) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:active_days) }
  it { should validate_numericality_of(:active_days).is_greater_than(0) }

  it 'trial' do
    expect(Plan.new({
      name: 'Trial'
    }).is_trial?).to be true
  end
end
