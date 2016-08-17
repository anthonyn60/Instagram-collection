require 'net/http'

class Collection < ApplicationRecord
	has_many :collection_posts
	has_many :posts, :through => :collection_posts

	validates_presence_of :tag, :start_time, :end_time, :on => :create
	validate :valid_tag, :valid_times

	def get_data
		results = JSON.parse(Net::HTTP.get(URI.parse(create_url)))
		puts results["data"]
		while !(results["pagination"]["next_url"].nil?) && ((results["data"].sort_by { |hash| hash['created_time'].to_i }.first["created_time"].to_i > end_time) || (results["data"].sort_by { |hash| hash['created_time'].to_i }.first["created_time"].to_i < start_time)) do
			puts "test"
			results = JSON.parse(Net::HTTP.get(URI.parse(results["pagination"]["next_url"])))
		end
		results["data"].each do |post_obj|
			tag_time = get_tag_time(post_obj)
			next unless tag_time != -1
			new_post = Hash.new
			new_post = {
				media_type: post_obj["type"],
				insta_link: post_obj["link"],
				media: get_media(post_obj),
				username: post_obj["user"]["username"],
				caption: post_obj["caption"]["text"],
				tag_time: tag_time,
				insta_id: post_obj["id"]
			}
			add_post(new_post)
		end
		self.next_url = no_more_data?(results) ? "No more" : results["pagination"]["next_url"]
		self.save
	end

	def add_post(new_post)
		existing = Post.where(insta_id: new_post[:insta_id])
		if existing.empty?
			created_post = self.posts.create!(media_type: new_post[:media_type],
				insta_link: new_post[:insta_link],
				media: new_post[:media],
				username: new_post[:username],
				caption: new_post[:caption],
				insta_id: new_post[:insta_id])
			CollectionPost.where(collection_id: id, post_id: created_post.id).first.update(tag_time: new_post[:tag_time])
		else
			if CollectionPost.where(collection_id: id, post_id: existing.first.id).empty?
				CollectionPost.create(collection_id: id.to_i, post_id: existing.first.id, tag_time: new_post[:tag_time])
			end
		end
	end

	def get_more_data
		unless self.next_url == "No more"
			get_data
		end
	end

	def get_tag_time(post)
		puts post["created_time"]
		if post["created_time"].to_i >= start_time && post["created_time"].to_i <= end_time
			if post["caption"]["text"].include? ('#' + tag)
				return post["caption"]["created_time"]
			else
				post_id = post["id"]
				access_token = ENV['ACCESS_TOKEN']
				comment_url = "https://api.instagram.com/v1/media/#{post_id}/comments?access_token=#{access_token}"
				comments = JSON.parse(Net::HTTP.get(URI.parse(comment_url)))
				comments["data"].each do |comment|
					puts "comment call"
					next unless comment["text"].include? ('#' + tag)
					return comment["created_time"]
				end
			end
		else
			return -1
		end
	end

	def no_more_data?(results)
		return results["pagination"]["next_url"].nil? || (results["data"].sort_by { |hash| hash['created_time'].to_i }.last["created_time"].to_i < start_time)
	end

	def get_media(post_obj)
		if post_obj["type"] == "video"
			return post_obj["videos"]["standard_resolution"]["url"]
		else
			return post_obj["images"]["standard_resolution"]["url"]
		end
	end

	def valid_tag
		if !tag.nil?
			unless tag.match(/^w*[a-zA-Z]+\w*$/)
				errors.add(:tag, "The tag format is invalid.")
			end
		end
	end

	def valid_times
		unless start_time < end_time
			errors.add(:start_time, "The start time must be before the end time.")
		end
	end

	def create_url
		access_token = ENV['ACCESS_TOKEN']
		return next_url.nil? ? "https://api.instagram.com/v1/tags/#{tag}/media/recent?access_token=#{access_token}" : next_url
	end
end
