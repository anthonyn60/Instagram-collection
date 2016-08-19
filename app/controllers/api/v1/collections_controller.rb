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
					collection.get_data
					render json: { id: collection.id,
						start_time: collection.start_time,
						end_time: collection.end_time,
						posts: collection.posts.select('posts.*, collection_posts.tag_time').as_json(except: [:created_at, :updated_at]),
						name: collection.name,
						tag: collection.tag,
						current_count: posts.count }
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
				ten_at_page = (params[:page].to_i + 1) * 10
				#ten_at_page = (ten_at_page + 1) * 10
				posts = collection.first.posts.select('posts.*, collection_posts.tag_time').paginate(:page => params[:page], :per_page => 10)
				while (posts.empty? || (posts.count < ten_at_page)) && collection.first.next_url != "No more"
					get_more_posts
					posts = collection.first.posts.select('posts.*, collection_posts.tag_time').paginate(:page => params[:page], :per_page => 10)
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
					current_count: posts.count }
				end
			end
		end

		def get_all_collections
			collections = Collection.all.order(created_at: :desc)
			render json: collections, except: [:updated_at]
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
