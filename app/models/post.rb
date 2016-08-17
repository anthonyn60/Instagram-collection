class Post < ApplicationRecord
	has_many :collection_posts
	has_many :collections, :through => :collection_posts, extend: CollectionPost
end
