require 'rails_helper'

RSpec.describe Admin::BooksController, :type => :controller do
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
      it { expect(assigns(:books)).to_not be_nil }
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
          book = double('book')
          renderer = double('renderer')

          allow(book).to receive(:save).and_return(true)
          allow(Book).to receive(:new).with(
            title: 'Test Title', 
            author: 'Test Author',
            cover: 'Test/Image',
            recommend: 'Test Recommend',  
            summary: 'Test Content', 
            tag_list: 'Test-Tag-1, Test-Tag-2',
            keys: ['Test-Key-1', 'Test-Key-2'], 
            lessons: ['Test-Lesson-1', 'Test-Lesson-2'], 
          ).and_return(book)

          allow(renderer).to receive(:render).with('Test Content').and_return('Test Content')
          allow(Redcarpet::Markdown).to receive(:new).and_return(renderer)

          sign_in superuser
          xhr :post, :create, book: { 
            title: 'Test Title', 
            author: 'Test Author',
            cover: 'Test/Image',
            recommend: 'Test Recommend',  
            summary: 'Test Content', 
            keys: ['Test-Key-1|Test-Key-2'], 
            lessons: ['Test-Lesson-1|Test-Lesson-2'], 
            tag_list: 'Test-Tag-1, Test-Tag-2'
          }
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:create) }
        it { should use_after_action(:flash_to_headers) }
        it { expect(assigns(:books)).to_not be_nil }
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :post, :create, book: { 
            title: 'Test Title', 
            author: 'Test Author',
            cover: 'Test/Image',
            recommend: 'Test Recommend',  
            summary: 'Test Content', 
            keys: ['Test-Key-1|Test-Key-2'], 
            lessons: ['Test-Lesson-1|Test-Lesson-2'], 
            tag_list: 'Test-Tag-1, Test-Tag-2'
          }
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#edit' do
    let(:book) { double('book', id: '123') }
    before do
      allow(Book).to receive(:find).and_return(book)
    end

    context '#xhr' do 
      context 'when logged in' do
        before do
          allow(book).to receive(:summary)
          allow(book).to receive(:summary=)
          allow(ReverseMarkdown).to receive(:convert)

          sign_in superuser
          xhr :get, :edit, id: book
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:edit) }
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :get, :edit, id: book
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#update' do
    let(:book) { double('book', id: '123') }
    before do
      allow(Book).to receive(:find).and_return(book)
    end

    context '#xhr' do      
      context 'when logged in' do
        before do
          renderer = double('renderer')

          allow(book).to receive(:update_attributes).with(
            title: 'Test Update Title', 
            author: 'Test Update Author',
            cover: 'Test/UpdateImage',
            summary: 'Test Content'
          ).and_return(true)

          allow(renderer).to receive(:render).with('Test Content').and_return('Test Content')
          allow(Redcarpet::Markdown).to receive(:new).and_return(renderer)

          sign_in superuser
          xhr :put, :update, id: book, book: { 
            title: 'Test Update Title', 
            author: 'Test Update Author',
            cover: 'Test/UpdateImage',
            summary: 'Test Content'
          }
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:update) }
        it { expect(assigns(:books)).to_not be_nil }
        it { should use_after_action(:flash_to_headers) }
      end

      context 'when not logged in' do
        before do 
          sign_in nil
          xhr :put, :update, id: book, book: { 
            title: 'Test Update Title', 
            author: 'Test Update Author',
            cover: 'Test/UpdateImage',
            summary: 'Test Content'
          }
        end

        it { should respond_with 401 }
      end
    end
  end

  describe '#destroy' do
    let(:book) { double('book', id: '123') }
    before do
      allow(Book).to receive(:find).and_return(book)
    end

    context '#xhr' do
      context 'when logged in' do
        before do
          allow(book).to receive(:destroy).and_return(true)

          sign_in superuser
          xhr :delete, :destroy, id: book
        end

        it { should respond_with 200 }
        it { expect(response).to render_template(:destroy) }
        it { should use_after_action(:flash_to_headers) }
        it { expect(assigns(:books)).to_not be_nil }
      end

      context 'when not logged in' do
        before { xhr :delete, :destroy, id: book }

        it { should respond_with 401 }
      end
    end
  end
end