Rails.application.routes.draw do

	get '/api/v1', :to => redirect('/api/v1/index.html')
	
	scope '/api' do
		scope module: 'api' do
			namespace 'v1' do
				post '/collections' => 'collections#create'
  				get '/collections/:id' => 'collections#read' 
  				get '/collections' => 'collections#get_all_collections'
			end
		end
	end	
end
