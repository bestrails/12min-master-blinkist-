class LibraryController < ApplicationController
  before_action :authenticate_user!
  before_action :library, only: [:index]

  def index
    filtered_books
  end  
end
