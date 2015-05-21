require 'rails_helper'

RSpec.describe SubscriptionsController, :type => :controller do
  describe '#index' do
    context 'when logged in' do
      before do
        sign_in
        xhr :get, :index
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:index) }
      it "should assigns plans" do 
        expect(assigns(:plans)).to_not be_nil
      end
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        xhr :get, :index
      end

      it { should respond_with 401 }
    end
  end

  describe '#update' do
    let(:user) { double('user') }
    let(:subscription) { double('subscription') }
    let(:plan) { double('plan', id: 'test') }

    context 'when logged in' do
      before do
        librarians = double('librarians')
        librarian = double('librarian')
        library = double('library')

        allow(librarian).to receive(:book)
        allow(librarians).to receive(:where).and_return([librarian])
        allow(library).to receive(:librarians).and_return(librarians)

        allow(user).to receive(:subscription).and_return(subscription)
        allow(user).to receive(:library).and_return(library)
        
        allow(subscription).to receive(:paused?).and_return(true)
        allow(Plan).to receive(:find).with('test').and_return(plan)

        expect(subscription).to receive(:update_attribute).with(:plan, plan)
        expect(subscription).to receive(:active)

        sign_in user
        xhr :put, :update, plan_id: plan.id
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:update) }
      it "should assigns plan" do 
        expect(assigns(:plan)).to_not be_nil
      end
      it "should assigns subscription" do 
        expect(assigns(:subscription)).to_not be_nil
      end
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        xhr :put, :update, plan_id: plan.id
      end

      it { should respond_with 401 }
    end
  end

  describe '#pay' do
    let(:user) { double('user', email: 'foo@bar') }
    let(:subscription) { double('subscription') }
    let(:plan) { double('plan', id: 'test', name: 'test', price: 1) }

    before do
      librarians = double('librarians')
      librarian = double('librarian')
      library = double('library')

      allow(librarian).to receive(:book)
      allow(librarians).to receive(:where).and_return([librarian])
      allow(library).to receive(:librarians).and_return(librarians)

      allow(user).to receive(:subscription).and_return(subscription)
      allow(user).to receive(:library).and_return(library)
      
      allow(subscription).to receive(:paused?).and_return(true)
      allow(Plan).to receive(:find).with('test').and_return(plan)
    end

    context 'when logged in' do
      before do
        charge = double('charge', success: true)

        expect(subscription).to receive(:update_attribute).with(:plan, plan)
        expect(subscription).to receive(:active)

        expect(user).to receive(:update_attribute).with(:token, '123')

        expect(Iugu::Charge).to receive(:create).with({
          token: '123',
          email: 'foo@bar',
          items: [{
            description: 'test',
            quantity: '1',
            price_cents: 1000
          }]
        }).and_return(charge)

        sign_in user
        xhr :put, :pay, token: '123', plan_id: plan.id
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:pay) }
    end

    context 'when promotion' do
      before do
        charge = double('charge', success: true)
        discount = double('discount', percentage: 10)
        plan_100 = double('plan', name: 'test-100', price: 100)

        allow(Plan).to receive(:find).with('test-100').and_return(plan_100)
        allow(Discount).to receive(:find_by_code).with('test').and_return(discount)

        expect(subscription).to receive(:update_attribute).with(:plan, plan_100)
        expect(subscription).to receive(:active)

        expect(user).to receive(:update_attribute).with(:token, '123')

        expect(Iugu::Charge).to receive(:create).with({
          token: '123',
          email: 'foo@bar',
          items: [{
            description: 'test-100',
            quantity: '1',
            price_cents: 90000
          }]
        }).and_return(charge)

        sign_in user
        xhr :put, :pay, token: '123', plan_id: 'test-100', coupon: 'test'
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:pay) }
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        xhr :put, :pay, token: '123', plan_id: plan.id
      end

      it { should respond_with 401 }
    end

    context 'when not send token' do
      before do 
        sign_in user
        xhr :put, :pay, plan_id: plan.id
      end

      it { should respond_with 400 }
    end
  end

  describe '#promotion' do
    let(:user) { double('user') }

    context 'when logged in' do
      before do
        allow(user).to receive(:discount_codes) { [] } 
        allow(Discount).to receive(:find_by_code).with('test-code') { Discount.new }
        allow(Plan).to receive(:find_by_name).with('Yearly') { Plan.new }

        sign_in user
        get :promotion, coupon: 'test-code'
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:promotion) }
      it "should assigns discount" do 
        expect(assigns(:discount)).to_not be_nil
      end
      it "should assigns yearly plan" do 
        expect(assigns(:yearly)).to_not be_nil
      end
    end

    context 'when discount does not exist' do
      before do
        allow(user).to receive(:discount_codes) { ['test'] } 
        allow(Discount).to receive(:find_by_code).with('test-code').and_raise(ActiveRecord::RecordNotFound)

        sign_in user
        get :promotion, coupon: 'test-code'
      end

      it { should respond_with 404 }
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        get :promotion, coupon: 'test-code'
      end

      it { should respond_with 200 }
    end
  end
end
