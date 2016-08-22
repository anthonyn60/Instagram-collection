module Api::V1
	class CollectionsController < ApplicationController
		def create
			if !Collection.where(name: params[:name], start_time: params[:start_time], end_time: params[:end_time], tag: params[:tag]).empty?
				collection = Collection.where(name: params[:name], start_time: params[:start_time], end_time: params[:end_time], tag: params[:tag]).first
				@collection_id = collection.id
				read
			else
				collection = Collection.new(collection_params)
				if collection.save
					render json: { id: collection.id,
						start_time: collection.start_time,
						end_time: collection.end_time,
						posts: collection.posts.select('posts.*, collection_posts.tag_time').order(:id).as_json(except: [:created_at, :updated_at]),
						name: collection.name,
						tag: collection.tag,
						current_count: collection.posts.count,
						next_url: collection.next_url}
					Thread.new do
						collection.get_data
					end
				else
					render json: {
						message: "The collection was not successfully created.",
						error: collection.errors
					}
				end
			end
		end

		def read
			@collection_id ||= params[:id]
			collection = Collection.where(id: @collection_id)
			if collection.empty?
				render json: {message: 'No posts found for this collection ID.', code: '404'}, status: :not_found
			else
				nine_at_page = (params[:page].to_i + 1) * 9
				posts = collection.first.posts.select('posts.*, collection_posts.tag_time').order(:id).paginate(:page => params[:page], :per_page => 9)
				while (posts.empty? || (posts.count < nine_at_page)) && collection.first.next_url != "No more"
					get_more_posts
					posts = collection.first.posts.select('posts.*, collection_posts.tag_time').order(:id).paginate(:page => params[:page], :per_page => 9)
					if posts.count < 9 #stop neverending polling on lock
						break
					end
				end
				if posts.empty? 
					render json: {message: 'There are no remaining posts for this collection.', code: '404'}, status: :not_found
				else
					render json: { id: collection.first.id,
					posts: posts.as_json(:except => [:created_at, :updated_at]),
					start_time: collection.first.start_time,
					end_time: collection.first.end_time,
					name: collection.first.name,
					tag: collection.first.tag,
					next_url: collection.first.next_url,
					current_count: posts.count }
				end
			end
		end

		def get_all_collections
			collections = Collection.all.order(created_at: :desc).paginate(:page => params[:page], :per_page => 9)
			render json: collections, except: [:updated_at, :next_url, :locked], methods: :media_link
		end

		def get_more_posts
			@collection_id ||= params[:id]
			collection = Collection.where(id: @collection_id)
			if collection.nil?
				render json: {message: 'This collection does not exist.', code: '404'}, status: :not_found
			elsif collection.first.next_url == "No more"
				render json: {message: 'There are no more posts for this collection.', code: '404'}, status: :not_found
			else
				collection.first.get_more_data
			end
		end

		def collection_params
			params.require(:collection).permit(:name, :start_time, :end_time, :tag)
		end
	end
end
