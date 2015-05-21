module Constraint
  class BookUrlConstrainer
    def matches?(request)
      id = request.path.gsub("/", "")
      Book.find_by_slug(id)
    end
  end
end