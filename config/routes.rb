Rails.application.routes.draw do
	scope '/api' do
		scope module: 'api' do
			namespace 'v1' do
				post '/collections' => 'collections#create'
  				get '/collections' => 'collections#read' 
			end
		end
	end	
end
