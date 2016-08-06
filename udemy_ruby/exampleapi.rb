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

puts response.body
