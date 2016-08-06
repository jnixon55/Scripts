require 'rubygems'
require 'httparty'

# class EdutechionalResty
#   include HTTParty
#   base_uri "api.twitter.com/"
#
#   def posts
#     self.class.get('/1.1/statuses/mentions_timeline.json')
#   end
# end
#
# edutechional_resty = EdutechionalResty.new
# puts edutechional_resty.posts

response = HTTParty.get('http://api.stackexchange.com/2.2/questions?site=stackoverflow')

# puts response.body
# puts response.code
# puts response.messege
# puts response.headers.inspect

class StackExchange
  include HTTParty
  base_uri 'api.stackexchange.com'

  def initialize(service, page)
    @options = {query: {site: service}}
  end

  def questions
    self.class.get('/2.2/questions', @options)
  end

  def users
    self.class.get('/2.2/users', @options)
  end
end

stack_exchange = StackExchange.new('stackoverflow', 1)

# puts stack_exchange.questions
puts stack_exchange.users
