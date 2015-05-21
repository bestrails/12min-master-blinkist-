class Librarian < ActiveRecord::Base
  belongs_to :library
  belongs_to :book

  state_machine :state, :initial => :unread do
    event :read do
      transition :unread => :read
    end
  end
end
