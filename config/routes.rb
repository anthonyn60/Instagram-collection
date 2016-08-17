Rails.application.routes.draw do
	scope '/api' do
		scope module: 'api' do
			namespace 'v1' do
				post '/collection' => 'collections#create'
  				get '/collection' => 'collections#read' 
			end
		end
	end	
end
