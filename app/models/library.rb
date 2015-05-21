class Library < ActiveRecord::Base
  belongs_to :user
  
  has_many :librarians
  has_many :books, -> { uniq }, through: :librarians
end
