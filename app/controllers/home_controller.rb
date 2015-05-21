class HomeController < ApplicationController
  before_action :books, only: [:index, :landing]
  before_action :plans, only: [:pricing]

  def pricing
  end

  def landing
    @books = Book.all.limit(8).order("RANDOM()")
  end
end
