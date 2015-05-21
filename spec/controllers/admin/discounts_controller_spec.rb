require 'rails_helper'

RSpec.describe Admin::DiscountsController, :type => :controller do
  let(:superuser) { double('user') }
  before { allow(superuser).to receive(:superuser?).and_return(true) }

  describe '#index' do
    context 'when logged in' do
      before do
        sign_in superuser
        get :index
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:index) }
      it { expect(assigns(:discounts)).to_not be_nil }
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        get :index
      end

      it { should respond_with 302 }
    end

    context 'when not superuser' do
      before do 
        user = double('user')
        allow(user).to receive(:superuser?).and_return(false)

        sign_in user
        get :index
      end

      it { should redirect_to(root_path) }
    end
  end

  describe '#new' do
    context '#xhr' do 
      context 'when logged in' do
        before do
          sign_in superuser
          xhr :get, :new
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:new) }
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :get, :new
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#create' do
    context '#xhr' do 
      context 'when logged in' do
        before do
          discount = double('discount')

          allow(discount).to receive(:save).and_return(true)
          allow(Discount).to receive(:new).with(
            code: 'CODE', 
            percentage: '10'
          ).and_return(discount)

          sign_in superuser
          xhr :post, :create, discount: { 
            code: 'CODE', 
            percentage: '10'
          }
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:create) }
        it { should use_after_action(:flash_to_headers) }
        it { expect(assigns(:discounts)).to_not be_nil }
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :post, :create, discount: { 
            code: 'CODE', 
            percentage: '10'
          }
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#edit' do
    let(:discount) { double('discount', id: '123') }
    before do
      allow(Discount).to receive(:find).and_return(discount)
    end

    context '#xhr' do 
      context 'when logged in' do
        before do
          sign_in superuser
          xhr :get, :edit, id: discount
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:edit) }
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :get, :edit, id: discount
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#update' do
    let(:discount) { double('discount', id: '123') }
    before do
      allow(Discount).to receive(:find).and_return(discount)
    end

    context '#xhr' do      
      context 'when logged in' do
        before do
          allow(discount).to receive(:update_attributes).with(
            code: 'UPDATED'
          ).and_return(true)

          sign_in superuser
          xhr :put, :update, id: discount, discount: { 
            code: 'UPDATED'
          }
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:update) }
        it { expect(assigns(:discounts)).to_not be_nil }
        it { should use_after_action(:flash_to_headers) }
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :put, :update, id: discount, discount: { 
            code: 'UPDATED'
          }
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#destroy' do
    let(:discount) { double('discount', id: '123') }
    before do
      allow(Discount).to receive(:find).and_return(discount)
    end

    context '#xhr' do
      context 'when logged in' do
        before do
          allow(discount).to receive(:destroy).and_return(true)

          sign_in superuser
          xhr :delete, :destroy, id: discount
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:destroy) }
        it { should use_after_action(:flash_to_headers) }
        it { expect(assigns(:discounts)).to_not be_nil }
      end

      context 'when not logged in' do
        before { xhr :delete, :destroy, id: discount }

        it { should respond_with 401 }
      end
    end
  end
end