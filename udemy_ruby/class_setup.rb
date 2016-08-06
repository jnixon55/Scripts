class ApiConnector
  attr_accessor :title, :description, :url

  def initialize(title: title, description: description, url: url = "google.com")
    @title = title
    @description = description
    @url = url
 end

 def test_initializers
   puts @title
   puts @description
   puts @url
 end
end

api = ApiConnector.new(description: "My description",title: "My Title", url: "urbangeek.company")

api.test_initializers
