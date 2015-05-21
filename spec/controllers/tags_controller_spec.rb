require 'rails_helper'

RSpec.describe TagsController, :type => :controller do
  describe '#index' do
    before do
      allow(ActsAsTaggableOn::Tag).to receive(:all) { [] }

      sign_in
      xhr :get, :index
    end

    it { should respond_with 200 }
    it { expect(response.body).to_not be_nil }
    it { expect(response).to have_content_type('application/json') }
  end

  describe '#show' do
    context 'when select a category' do
      let(:tag) { ActsAsTaggableOn::Tag.create(name: 'test') }

      before do
        allow(ActsAsTaggableOn::Tag).to receive(:all) { [] }
        allow(ActsAsTaggableOn::Tag).to receive(:find) { tag }
        allow(Book).to receive(:tagged_with).with(tag.name) { [] }

        sign_in
        xhr :get, :show, id: tag
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:show) }
      it "should assigns books" do 
        expect(assigns(:books)).to_not be_nil
      end
      it "should assigns tag" do 
        expect(assigns(:tag)).to_not be_nil
      end
      it "should assigns tags" do 
        expect(assigns(:tags)).to_not be_nil
      end
    end

    context 'when select \'all\'' do
      before do
        expect(Book).to receive(:all)

        sign_in
        xhr :get, :show, id: 'all'
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:show) }
      it "should assigns tag_wildcard" do 
        expect(assigns(:tag_wildcard)).to_not be_nil
      end
      it "should assigns tags" do 
        expect(assigns(:tags)).to_not be_nil
      end
    end

    context 'when select \'recent\'' do
      before do
        books = double('books')

        allow_any_instance_of(Time).to receive(:advance).with(days: -30).and_return(Time.parse('2015-01-01'))
        expect(Book).to receive(:order).with(created_at: :desc).and_return(books)
        expect(books).to receive(:limit).with(5)

        sign_in
        xhr :get, :show, id: 'recent'
      end

      it { should respond_with 200 }
      it { expect(response).to render_template(:show) }
      it "should assigns tag_wildcard" do 
        expect(assigns(:tag_wildcard)).to_not be_nil
      end
      it "should assigns tags" do 
        expect(assigns(:tags)).to_not be_nil
      end
    end
  end
end
