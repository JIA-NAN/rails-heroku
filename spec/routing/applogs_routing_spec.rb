require 'spec_helper'

describe ApplogsController do
  describe 'routing' do
    it 'routes to #index' do
      get('/applogs').should route_to('applogs#index')
    end
    it 'routes to #new' do
      get('/applogs/new').should route_to('applogs#new')
    end
    it 'routes to #show' do
      get('/applogs/1').should route_to('applogs#show', id: '1')
    end
    it 'routes to #edit' do
      get('/applogs/1/edit').should route_to('applogs#edit', id: '1')
    end
    it 'routes to #create' do
      post('/applogs').should route_to('applogs#create')
    end
    it 'routes to #update' do
      put('/applogs/1').should route_to('applogs#update', id: '1')
    end
    it 'routes to #destroy' do
      delete('/applogs/1').should route_to('applogs#destroy', id: '1')
    end
  end
end
