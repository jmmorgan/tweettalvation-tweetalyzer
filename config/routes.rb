Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # You can have the root of your site routed with "root"
  root 'welcome#index', via: ['get']

  match '/expand_reviews', to: 'welcome#expand_reviews', via: ['get', 'post']
  match '/expand_timeline_graph', to: 'welcome#expand_timeline_graph', via: ['get', 'post']
  match '/timeline_graph_data', to: 'welcome#timeline_graph_data', via: ['get', 'post']
end
