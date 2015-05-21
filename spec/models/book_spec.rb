require 'rails_helper'

RSpec.describe Book, :type => :model do
  it { should have_and_belong_to_many(:libraries) }
  it { should validate_uniqueness_of(:title) }
end
