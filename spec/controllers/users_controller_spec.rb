require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  let(:user) { double('user', name: 'Test') }

  describe '#show' do
    context 'when logged in' do
      before do
        sign_in user
        xhr :get, :show, id: user
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:show) }
      it "should assigns current user" do 
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        xhr :get, :show, id: user
      end

      it { should respond_with 401 }
    end
  end

  describe '#destroy' do
    before do
      allow(user).to receive(:destroy)
    end

    context 'when logged in' do
      before do
        sign_in user
        xhr :delete, :destroy, id: user
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:destroy) }
      it "should assigns current user" do 
        expect(assigns(:user)).to eq(user)
      end
      it "should flash not be nil" do 
        expect(flash).to_not be_nil
      end
    end

    context 'when not logged in' do
      before { xhr :delete, :destroy, id: user }

      it { should respond_with 401 }
    end
  end

  describe '#edit' do
    context 'when logged in' do
      before do
        sign_in user
        xhr :get, :edit, id: user
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:edit) }
      it "should assigns current user" do 
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        xhr :get, :edit, id: user
      end

      it { should respond_with 401 }
    end
  end

  describe '#update' do
    context 'when logged in' do
      before do
        allow(Devise::Mapping).to receive(:find_scope!).and_return(user)

        allow(user).to receive(:update_attributes).with({
          password: 'TestTest',
          password_confirmation: 'TestTest'
        }).and_return(true)

        sign_in user
        xhr :put, :update, id: user, user: { 
          password: 'TestTest',
          password_confirmation: 'TestTest'
        }
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:show) }
      it "should assigns current user" do 
        expect(assigns(:user)).to eq(user)
      end
      it "should flash not be nil" do 
        expect(flash).to_not be_nil
      end
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        xhr :put, :update, id: user, user: { 
          password: 'TestTest',
          password_confirmation: 'TestTest'
        }
      end

      it { should respond_with 401 }
    end
  end

  describe '#set_session_close_info' do
    context 'when logged in' do
      before do
        sign_in user
        xhr :put, :set_session_close_info
      end

      it { should respond_with 200 }
      it { expect(session[:close_info]).not_to be_nil }
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        xhr :put, :set_session_close_info
      end

      it { should respond_with 401 }
    end
  end
end