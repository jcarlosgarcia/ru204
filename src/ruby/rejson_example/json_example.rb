require 'redis'
require 'rejson'

BOOK_KEY = "ru204:book:99999"

BOOK = {
  author: "Redis University",
  id: 99999,
  description: "This is a fictional book used to demonstrate RedisJSON!",
  editions: [
    "english",
    "french"
  ],
  genres: [
    "education",
    "technology"
  ],
  inventory: [
    {
      status: "available",
      stock_id: "99999_1"
    },
    {
      status: "on_loan",
      stock_id: "99999_2"
    }
  ],
  metrics: {
    rating_votes: 12,
    score: 2.3
  },
  pages: 1000,
  title: "Up and Running with RedisJSON",
  url: "https://university.redis.com/courses/ru204/",
  year_published: 2022
}

# Create a connection to Redis and connect to the server.
REDIS_URL = ENV.fetch("REDIS_URL", "redis://localhost:6379/")

puts "Connecting to Redis at #{REDIS_URL}"
r = Redis.new(url: REDIS_URL)

# Delete any previous data at our book's key
r.del BOOK_KEY

# Store the book in Redis at key ru204:book:99999...
# Response will be: True
response = r.json_set(BOOK_KEY, Rejson::Path.root_path, BOOK)
puts "Book stored: #{response}"

# Let's get the author and score for this book...
# Response will be:
# {'$.author': ['Redis University'], '$.metrics.score': [2.3]}
response = r.json_get(BOOK_KEY, Rejson::Path.new(".author"), Rejson::Path.new(".metrics.score"))

puts "Author and score:"
puts response

# Add one to the number of rating_votes:
# Response will be: [13]
response = r.json_numincrby(BOOK_KEY, Rejson::Path.new(".metrics.rating_votes"), 1)
puts "rating_votes incremented to #{response}"

# Add another copy of the book to the inventory.
# Response will be: [3] (new size of the inventory array)
response = r.json_arrappend(BOOK_KEY, Rejson::Path.new(".inventory"), {
  status: "available",
  stock_id: "99999_3"
})

puts "There are now #{response} copies of the book in the inventory."
