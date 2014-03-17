class Book
@@book_ids= []
attr_accessor :id,:title, :authors, :isbn
def initialize(title,authors,isbn)
	@id = generate_id
  @title = title
	@authors = authors	
	@isbn = isbn
  @@book_ids.push(self.id)
end


def generate_id
	(0...8).map { (65 + rand(26)).chr }.join
end

def self.book_list
	@@book_ids
end

end
	
class User
attr_accessor :id, :name, :email

def initialize(name,email)

end

end
b = Book.new("wasi",["we","re"],"123")
p Book.book_list
