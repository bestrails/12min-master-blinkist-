require 'rails_helper'

RSpec.describe Users::InvitationsController, :type => :controller do
  let(:invited) { User.new({ email: 'invited@bar.test', password: '123456' }) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    allow(User).to receive(:find_by_invitation_token) { invited }
  end

  describe '#edit' do
    let(:user) { double('user', email: 'foo@bar') }

    before do
      allow(User).to receive(:find_by_referral_code).with('123456') { user }
      get :edit, referral_code: '123456', invitation_token: '123456'
    end

    it "should assigns referral_code" do 
      expect(assigns(:referral_code)).to eq('123456')
    end
  end

  describe '#update' do
    let(:user) { double('user', email: 'foo@bar') }

    before do
      mailer = double('mailer')

      allow(mailer).to receive(:deliver)
      allow(UsersMailer).to receive(:accepted_invite).and_return(mailer)
      allow(User).to receive(:accept_invitation!) { invited }
      allow(User).to receive(:find_by_referral_code).with('123456') { user }
      allow(Plan).to receive(:find_by_name) { Plan.new(name: 'Test', active_days: 3) }
    end

    it "should call user referral" do 
      expect(user).to receive(:referral).with(invited)
      put :update, inviter: { referral_code: '123456' }, invitation_token: '123456'
    end
  end

  describe '#new' do
    context '#xhr' do
      before do
        sign_in
        xhr :get, :new
      end

      it { expect(response).to render_template(:new) }
    end
  end

  describe '#create' do
    context '#xhr' do
      before do
        allow_any_instance_of(User).to receive(:invite!) { true }
        allow_any_instance_of(User).to receive(:primary_key) { 1 }

        user = User.new ({ email: 'foo@bar.test', password: '123456' })
        allow(user).to receive(:has_invitations_left?) { true }

        sign_in user
        xhr :post, :create, referring: { emails: 'invited@bar.test' }
      end

      it { expect(response).to render_template(:create) }
    end
  end
end