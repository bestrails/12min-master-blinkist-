class BooksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :books, only: [:index]
  before_action :book, only: [:pick, :content, :read, :show, :pocket, :kindle]
  before_action :librarian, only: [:read]
  before_action :read_now?, only: [:content]

  after_action :track_pick_book, only: [:pick]
  after_action :track_read_book, only: [:read]

  rescue_from CanCan::AccessDenied do |exception|
    if action_name.eql?('kindle') || action_name.eql?('pocket') 
      response.headers['X-Message'] = URI::encode t('books.limit')
      response.headers["X-Message-Type"] = 'danger'

      render :nothing => true, :status => 401
    end
  end
  
  def index
    respond_to do |format|
      format.html
      format.json { render json: @books }
    end
  end

  def show
  end

  def pick
    authorize! :pick, @book
    
    current_user.library.books.push(@book)
    render :update
  end

  def content
    authorize! :read, @book

    @content = @book.summary
    render layout: false
  end

  def read
    authorize! :read, @book
    
    @librarian.read
    redirect_to library_index_path
  end

  def pocket
    authorize! :pocket, @book
    
    begin
      UsersMailer.send_to_pocket(params[:pocket_email], content_book_url(@book)).deliver_now!
      current_user.add_pocket
      flash[:notice] = t('books.send_to_pocket.success')
      
      render :nothing => true, :status => 200
    rescue
      flash[:error] = t('books.send_to_pocket.failure')
      render :nothing => true, :status => 500
    end
  end

  def kindle
    authorize! :kindle, @book
    
    begin
      UsersMailer.send_to_kindle(current_user.kindle, @book).deliver
      current_user.add_kindle
      flash[:notice] = t('books.send_to_kindle.success')
      
      render :nothing => true, :status => 200
    rescue
      flash[:error] = t('books.send_to_kindle.failure')
      render :nothing => true, :status => 500
    end
  end

  private
  def book
    @book = Book.friendly.find(params[:id])
  end

  def librarian
    @librarian = current_user.library.librarians.find_by(book: @book)
  end

  def read_now?
    if(!can?(:read, @book) && can?(:pick, @book))
      current_user.library.books.push(@book)
    end
  end

  def track_pick_book
    return unless ENV['SEGMENT_IO_KEY']
    Analytics.track(
      user_id: current_user.id,
      event: 'Book added',
      properties: {
        title: @book.title,
        category: @book.tags.map(&:name).join(','),
        author: @book.author
    })
  end

  def track_read_book
    return unless ENV['SEGMENT_IO_KEY']
    Analytics.track(
      user_id: current_user.id,
      event: 'Book finished',
      properties: {
        title: @book.title,
        category: @book.tags.map(&:name).join(','),
        author: @book.author
    })
  end
end
