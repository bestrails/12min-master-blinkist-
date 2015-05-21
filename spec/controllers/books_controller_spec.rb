require 'rails_helper'

RSpec.describe BooksController, :type => :controller do
  describe '#index' do
    context 'when logged in' do
      before do
        sign_in
        get :index
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:index) }
      it "should assigns books" do 
        expect(assigns(:books)).to_not be_nil
      end
    end

    context 'when search a book' do
      before do
        expect(Book).to receive(:search_full_text).with('Test').and_return([])

        sign_in
        get :index, search: 'Test'
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:index) }
      it "should assigns books" do 
        expect(assigns(:books)).to_not be_nil
      end
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        get :index
      end

      it { should respond_with 302 }
    end
  end

  describe '#pick' do
    context '#xhr' do
      let(:book) { double('book', id: '123') }
      
      context 'when logged in with trial subscription' do
        before do
          library = double('library', books: [])
          user = double('user')
          subscription = double('subscription')
          plan = double('plan')
          friendly = double('friendly')

          allow(plan).to receive(:books_limit).and_return(3)
          allow(plan).to receive(:is_trial?).and_return(true)
          
          allow(subscription).to receive(:actived?).and_return(true)
          allow(subscription).to receive(:plan).and_return(plan)

          allow(user).to receive(:subscription).and_return(subscription)
          allow(user).to receive(:library).and_return(library)
          allow(user).to receive(:superuser?).and_return(false)

          allow(Book).to receive(:friendly).and_return(friendly)
          allow(friendly).to receive(:find).and_return(Book.new)

          sign_in user
          xhr :put, :pick, id: book.id
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:update) }
        it "should assigns book" do 
          expect(assigns(:book)).to_not be_nil
        end
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :put, :pick, id: book.id
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#content' do
    let(:book) { Book.create(title: 'test') }

    context 'when logged in' do
      before do
        librarian = double('librarian')
        librarians = double('librarians')
        library = double('library', books: [])
        user = double('user')
        subscription = double('subscription')
        plan = double('plan')
        books = double('books')

        allow(plan).to receive(:is_trial?).and_return(false)

        allow(subscription).to receive(:actived?).and_return(true)
        allow(subscription).to receive(:plan).and_return(plan)

        allow(librarian).to receive(:read)
        allow(librarians).to receive(:find_by).and_return(librarian)
        
        allow(books).to receive(:include?).and_return(true)
        allow(books).to receive(:push)

        allow(library).to receive(:librarians).and_return(librarians)
        allow(library).to receive(:books).and_return(books)

        allow(user).to receive(:library).and_return(library)
        allow(user).to receive(:subscription).and_return(subscription)
        allow(user).to receive(:superuser?).and_return(false)

        sign_in user
        get :content, id: book
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:content) }
      it "should assigns content" do 
        expect(assigns(:content)).to eq(book.summary)
      end
    end

    context 'when not logged in' do
      before do 
        sign_in nil
        get :content, id: book
      end

      it { should respond_with 302 }
    end
  end

  describe '#read' do
    context '#xhr' do
      let(:book) { Book.create(title: 'test') }
      
      context 'when logged in with an active subscription' do
        before do
          librarian = double('librarian')
          librarians = double('librarians')
          library = double('library')
          user = double('user')
          subscription = double('subscription')
          plan = double('plan')
          books = double('books')

          allow(plan).to receive(:is_trial?).and_return(false)

          allow(subscription).to receive(:actived?).and_return(true)
          allow(subscription).to receive(:plan).and_return(plan)

          allow(librarian).to receive(:read)
          allow(librarians).to receive(:find_by).and_return(librarian)
          
          allow(books).to receive(:include?).and_return(true)

          allow(library).to receive(:librarians).and_return(librarians)
          allow(library).to receive(:books).and_return(books)

          allow(user).to receive(:library).and_return(library)
          allow(user).to receive(:subscription).and_return(subscription)
          allow(user).to receive(:superuser?).and_return(false)

          sign_in user
          xhr :put, :read, id: book.id
        end

        it { should respond_with 302 }
        it { expect(response).to redirect_to(library_index_path) }
        it "should assigns book" do 
          expect(assigns(:book)).to_not be_nil
        end
        it "should assigns librarian" do 
          expect(assigns(:librarian)).to_not be_nil
        end
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :put, :read, id: book.id
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#show' do
    let(:book) { double('book', id: '123') }
    before do 
      friendly = double('friendly')

      allow(Book).to receive(:friendly).and_return(friendly)
      allow(friendly).to receive(:find).and_return(book)
    end

    context '#html' do
      before do
        sign_in
        get :show, id: book
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:show) }
      it "should assigns book" do 
        expect(assigns(:book)).to_not be_nil
      end
    end

    context '#xhr' do
      context 'when logged in' do
        before do
          sign_in
          xhr :get, :show, id: book
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:show) }
        it "should assigns book" do 
          expect(assigns(:book)).to_not be_nil
        end
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :get, :show, id: book
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:show) }
        it "should assigns book" do 
          expect(assigns(:book)).to_not be_nil
        end
      end
    end
  end

  describe '#pocket' do
    context '#xhr' do
      let(:book) { Book.create(title: 'test') }
      
      context 'when logged in with an active subscription' do
        before do
          librarian = double('librarian')
          librarians = double('librarians')
          library = double('library')
          user = double('user')
          subscription = double('subscription')
          plan = double('plan')
          books = double('books')
          mailer = double('mailer')

          allow(plan).to receive(:is_trial?).and_return(false)
          allow(plan).to receive(:pocket_limit).and_return(5)

          allow(subscription).to receive(:actived?).and_return(true)
          allow(subscription).to receive(:plan).and_return(plan)
          allow(subscription).to receive(:pocket).and_return(0)

          allow(librarian).to receive(:read)
          allow(librarians).to receive(:find_by).and_return(librarian)
          
          allow(books).to receive(:include?).and_return(true)

          allow(library).to receive(:librarians).and_return(librarians)
          allow(library).to receive(:books).and_return(books)

          allow(user).to receive(:library).and_return(library)
          allow(user).to receive(:subscription).and_return(subscription)
          allow(user).to receive(:superuser?).and_return(false)
          allow(user).to receive(:add_pocket)

          allow(mailer).to receive(:deliver_now!)
          allow(UsersMailer).to receive(:send_to_pocket).with('test@pocket.com', content_book_url(book)).and_return(mailer)

          sign_in user
          xhr :put, :pocket, id: book.id, pocket_email: 'test@pocket.com'
        end

        it { should respond_with 200 }
        it "should assigns book" do 
          expect(assigns(:book)).to_not be_nil
        end
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :put, :pocket, id: book.id, pocket_email: 'test@pocket.com'
        end

        it { should respond_with 401 }
      end

      context 'when sent pocket is gretar than the limit' do
        before do
          librarian = double('librarian')
          librarians = double('librarians')
          library = double('library')
          user = double('user', kindle: 'test@kindle.com')
          subscription = double('subscription')
          plan = double('plan')
          books = double('books')
          mailer = double('mailer')

          allow(plan).to receive(:is_trial?).and_return(false)
          allow(plan).to receive(:pocket_limit).and_return(5)

          allow(subscription).to receive(:actived?).and_return(true)
          allow(subscription).to receive(:plan).and_return(plan)
          allow(subscription).to receive(:pocket).and_return(5)

          allow(librarian).to receive(:read)
          allow(librarians).to receive(:find_by).and_return(librarian)
          
          allow(books).to receive(:include?).and_return(true)

          allow(library).to receive(:librarians).and_return(librarians)
          allow(library).to receive(:books).and_return(books)

          allow(user).to receive(:library).and_return(library)
          allow(user).to receive(:subscription).and_return(subscription)
          allow(user).to receive(:superuser?).and_return(false)

          sign_in user
          xhr :put, :pocket, id: book.id
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#kindle' do
    context '#xhr' do
      let(:book) { Book.create(title: 'test') }
      
      context 'when logged in with an active subscription' do
        before do
          librarian = double('librarian')
          librarians = double('librarians')
          library = double('library')
          user = double('user', kindle: 'test@kindle.com')
          subscription = double('subscription')
          plan = double('plan')
          books = double('books')
          mailer = double('mailer')

          allow(plan).to receive(:is_trial?).and_return(false)
          allow(plan).to receive(:kindle_limit).and_return(5)

          allow(subscription).to receive(:actived?).and_return(true)
          allow(subscription).to receive(:plan).and_return(plan)
          allow(subscription).to receive(:kindle).and_return(0)

          allow(librarian).to receive(:read)
          allow(librarians).to receive(:find_by).and_return(librarian)
          
          allow(books).to receive(:include?).and_return(true)

          allow(library).to receive(:librarians).and_return(librarians)
          allow(library).to receive(:books).and_return(books)

          allow(user).to receive(:library).and_return(library)
          allow(user).to receive(:subscription).and_return(subscription)
          allow(user).to receive(:superuser?).and_return(false)
          allow(user).to receive(:add_kindle)

          allow(mailer).to receive(:deliver)
          allow(UsersMailer).to receive(:send_to_kindle).with('test@kindle.com', book).and_return(mailer)

          sign_in user
          xhr :put, :kindle, id: book.id
        end

        it { should respond_with 200 }
        it "should assigns book" do 
          expect(assigns(:book)).to_not be_nil
        end
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :put, :kindle, id: book.id
        end

        it { should respond_with 401 }
      end

      context 'when sent kindle is gretar than the limit' do
        before do
          librarian = double('librarian')
          librarians = double('librarians')
          library = double('library')
          user = double('user', kindle: 'test@kindle.com')
          subscription = double('subscription')
          plan = double('plan')
          books = double('books')
          mailer = double('mailer')

          allow(plan).to receive(:is_trial?).and_return(false)
          allow(plan).to receive(:kindle_limit).and_return(5)

          allow(subscription).to receive(:actived?).and_return(true)
          allow(subscription).to receive(:plan).and_return(plan)
          allow(subscription).to receive(:kindle).and_return(5)

          allow(librarian).to receive(:read)
          allow(librarians).to receive(:find_by).and_return(librarian)
          
          allow(books).to receive(:include?).and_return(true)

          allow(library).to receive(:librarians).and_return(librarians)
          allow(library).to receive(:books).and_return(books)

          allow(user).to receive(:library).and_return(library)
          allow(user).to receive(:subscription).and_return(subscription)
          allow(user).to receive(:superuser?).and_return(false)

          sign_in user
          xhr :put, :kindle, id: book.id
        end

        it { should respond_with 401 }
      end
    end
  end
end
