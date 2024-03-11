require 'byebug'
require 'mongoid'

require 'minitest/autorun'

Mongoid.configure do |config|
  config.connect_to('mongoid_embedded_test')
end


Mongo::Logger.logger = Logger.new(STDOUT)
Mongo::Logger.logger.level = Logger::DEBUG
# increase log size limit
Mongo::Monitoring::CommandLogSubscriber::LOG_STRING_LIMIT = 10_000

###
# Models
###

class Post
  include Mongoid::Document

  field :title

  embeds_one :author
end

class Author
  include Mongoid::Document

  field :name

  embedded_in :post
  embeds_many :addresses
end

class Address
  include Mongoid::Document

  field :city

  embedded_in :author
end

###
# Test
###

class TestUpdateEmbedded < Minitest::Test
  def setup
    Post.delete_all
  end

  def test_assigning_embedded
    post = Post.create(title: 'foo')

    author = Author.new(name: 'bar')
    addresses = [Address.new(city: 'baz')]

    author.assign_attributes(addresses: addresses)
    post.assign_attributes(author: author)

    post.save!

    assert_nil post.reload.as_document['comments']
  end
end
