require 'rails_helper'

RSpec.describe BooksHelper, :type => :helper do
  describe '#action' do
    let(:user) { double('user') }
    let(:library) { double('library') }
    let(:book) { double('book', id: 'test') }
    let(:books) { double('books') }
    let(:subscription) { double('subscription') }
    let(:plan) { double('plan') }

    before(:each) do
      allow(user).to receive(:library).and_return(library)
      allow(user).to receive(:subscription).and_return(subscription)  
      
      allow(library).to receive(:books).and_return(books)

      allow(plan).to receive(:books_limit).and_return(3)
      allow(plan).to receive(:is_trial?).and_return(true)
      
      allow(subscription).to receive(:plan).and_return(plan)
    end

    context 'when user subscription is active' do
      before { allow(subscription).to receive(:actived?).and_return(true) }

      context 'when book is not in library' do
        before { allow(books).to receive(:include?).with(book).and_return(false) }

        it 'should returns \'Add to Library\' button' do
          expect(action(user, book).to_s).to eq( 
            '<div class="blink__button add-to-library" style="display:block">'\
              "<a class=\"button add-to-library\" data-method=\"put\" data-remote=\"true\" href=\"/books/test/pick\" rel=\"nofollow\">#{I18n.t('books.index.add_to_library')}</a>"\
            '</div>')
        end
      end

      context 'when book is in your library' do
        before { allow(books).to receive(:include?).with(book).and_return(true) }

        it 'should returns \'In your Library\' disabled button' do
          expect(action(user, book).to_s).to eq( 
            '<div class="blink__button already-in-library" style="display:block">'\
              "<button class=\"button already-in-library\" disabled=\"disabled\" name=\"button\" type=\"submit\">#{I18n.t('books.index.in_your_library')}</button>"\
            '</div>')
        end
      end
    end

    context 'when user subscription was expired' do
      before { allow(subscription).to receive(:actived?).and_return(false) }

      it 'should returns \'Subscribe now\' button' do
        expect(action(user, book).to_s).to eq( 
          '<div class="blink__button subscribe-now" style="display:block">'\
            "<a class=\"button subscribe-now\" data-remote=\"true\" href=\"/subscriptions\">#{I18n.t('books.index.subscribe_now')}</a>"\
          '</div>')
      end
    end
  end
end
