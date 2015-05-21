module BooksHelper
  def action(user, book)
    return content_tag :div, class: 'blink__button subscribe-now', style: 'display:block' do
      link_to I18n.t('books.index.subscribe_now'), subscriptions_path, { remote: true, :class => 'button subscribe-now' }
    end unless user.subscription.actived?
    
    unless user.library.books.include?(book)
      content_tag :div, class: 'blink__button add-to-library', style: 'display:block' do
        link_to I18n.t('books.index.add_to_library'), { :controller => 'books', :action => 'pick', :id => book.id }, { :class => 'button add-to-library', :method => :put, :remote => true }
      end
    else
      content_tag :div, class: 'blink__button already-in-library', style: 'display:block' do
        content_tag :button, I18n.t('books.index.in_your_library'), class: 'button already-in-library', disabled: "disabled", name: "button", type:"submit"
      end
    end
  end
end
