class TagsController < ApplicationController
  before_action :tags, only: [:index, :show]
  before_action :tag, only: [:show]

  def index
    render json: @tags.map(&:name)
  end

  def show
    books
  end

  private
  def tag
    unless params[:id].eql?('all') || params[:id].eql?('recent')
      @tag = ActsAsTaggableOn::Tag.find(params[:id])
    end
  end

  def books
    case params[:id]
    when 'all'
      @books = Book.all
      @tag_wildcard = t('layouts.application.all')
    when 'recent'
      @books = Book.order(created_at: :desc).limit(5)
      @tag_wildcard = t('layouts.application.recent')
    else
      @books = Book.tagged_with(@tag.name)
    end
  end
end
