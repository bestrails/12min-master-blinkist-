require 'rails_helper'

RSpec.describe HomeController, :type => :controller do
  describe '#landing' do
    context 'when not logged in' do
      before do 
        sign_in nil
        get :landing
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:landing) }
      it "should assigns books" do 
        expect(assigns(:books)).to_not be_nil
      end
    end
  end
end
