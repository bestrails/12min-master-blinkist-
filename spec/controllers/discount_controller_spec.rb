require 'rails_helper'

RSpec.describe DiscountController, :type => :controller do
  let(:user) { double('user') } 
  let(:subscription) { double('subscription') }

  before do
    plan = double('plan')
    library = double('library')
    librarians = double('librarians')
    librarian = double('librarian')

    allow(librarian).to receive(:book)
    allow(librarians).to receive(:where).and_return([librarian])
    allow(library).to receive(:librarians).and_return(librarians)
    
    allow(plan).to receive(:books_limit).and_return(3)
    allow(plan).to receive(:is_trial?).and_return(true)

    allow(subscription).to receive(:actived?).and_return(true)
    allow(subscription).to receive(:plan).and_return(plan)

    allow(user).to receive(:subscription).and_return(subscription)
    allow(user).to receive(:discount)
    allow(user).to receive(:library).and_return(library)
    allow(user).to receive(:superuser?).and_return(false)
  end

  describe '#index' do
    context 'when logged in' do
      before do
        allow(user).to receive(:discount_codes) { [] } 
        allow(Discount).to receive(:find_by_code).with('test-code') { Discount.new }

        sign_in user
        get :index, coupon: 'test-code'
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:index) }
      it "should assigns discount" do 
        expect(assigns(:discount)).to_not be_nil
      end
    end

    context 'when discount was offered' do
      before do
        allow(user).to receive(:discount_codes) { ['test'] } 
        allow(Discount).to receive(:find_by_code).with('test-code') { Discount.new({code: 'test'}) }

        sign_in user
      end

      subject { get :index, coupon: 'test-code' }

      it { expect(subject).to redirect_to library_index_path }
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        get :index, coupon: 'test-code'
      end

      it { should respond_with 302 }
    end
  end

  describe '#take' do
    context 'when logged in' do
      before do
        discount = double('discount')

        allow(Discount).to receive(:find_by_code).with('test-code') { discount }
        allow(subscription).to receive(:discounting).with(discount)

        sign_in user
        xhr :put, :take, coupon: 'test-code'
      end

      it { should respond_with 200 }
      it { expect(response).to render_template('library/index') }
      it "should assigns discount" do 
        expect(assigns(:discount)).to_not be_nil
      end
      it "should assigns library" do 
        expect(assigns(:library)).to_not be_nil
      end
      it "should assigns subscription" do 
        expect(assigns(:subscription)).to_not be_nil
      end
    end
  end
end
