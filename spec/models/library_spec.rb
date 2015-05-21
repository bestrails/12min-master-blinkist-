require 'rails_helper'

RSpec.describe Library, :type => :model do
  it { should belong_to(:user) }
  it { should have_and_belong_to_many(:books) }

  it 'should validate books uniqueness' do
    book = Book.create(title: 'Test')
    library = Library.create(user: User.new, books: [book])

    library.books.push book
    expect(library.books.count).to be(1)
  end
end
