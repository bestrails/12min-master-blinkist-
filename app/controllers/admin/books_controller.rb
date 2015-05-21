class Admin::BooksController < Admin::SuperusersController
  before_action :books, only: [:index]
  before_action :book, only: [:edit, :update, :destroy]
  before_action :create_book, only: [:create]

  load_and_authorize_resource
  
  def index
  end

  def new
  end

  def create
    if @book.save
      books && flash[:notice] = t('books.create.success')
    else
      flash[:error] = t('books.create.failure')
    end
  end

  def edit
    @book.summary = ReverseMarkdown.convert @book.summary
  end

  def update
    if @book.update_attributes(book_params)
      books && flash[:notice] = t('books.update.success')
    else
      flash[:error] = t('books.update.failure')
    end
  end

  def destroy
    if @book.destroy
      books && flash[:notice] = t('books.destroy.success')
    else
      flash[:error] = t('books.destroy.failure')
    end
  end

  private
  def book
    @book = Book.find(params[:id])
  end

  def create_book
    @book = Book.new(book_params)
  end

  def book_params
    ['keys', 'lessons'].each do |arr|
      params[:book][arr] = params[:book][arr][0].split('|') unless params[:book][arr].nil?
    end

    params[:book][:summary] = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {}).render(params[:book][:summary])

    params.require(:book).permit(:title, :author, :cover, :recommend, :summary, :tag_list, :keys => [], :lessons => [])
  end
end
