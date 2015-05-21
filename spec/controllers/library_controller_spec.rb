require 'rails_helper'

RSpec.describe LibraryController, :type => :controller do
  describe '#index' do
    context 'when logged in' do
      before do
        user = double('user')
        library = double('library')
        librarians = double('librarians')
        librarian = double('librarian')

        allow(librarian).to receive(:book)
        allow(librarians).to receive(:where).and_return([librarian])
        allow(library).to receive(:librarians).and_return(librarians)
        allow(user).to receive(:library).and_return(library)

        sign_in user
        xhr :get, :index
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:index) }
      it "should assigns library" do 
        expect(assigns(:library)).to_not be_nil
      end
      it "should assigns books" do 
        expect(assigns(:books)).to_not be_nil
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
end
