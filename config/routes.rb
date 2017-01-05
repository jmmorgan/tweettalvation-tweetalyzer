Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # You can have the root of your site routed with "root"
  match '/welcome', to: 'welcome#index', via: ['get']

  match '/expand_reviews', to: 'welcome#expand_reviews', via: ['get', 'post']
  match '/expand_timeline_graph', to: 'welcome#expand_timeline_graph', via: ['get', 'post']
  match '/timeline_graph_data', to: 'welcome#timeline_graph_data', via: ['get', 'post']

  match '/tweets', to: 'tweet#index', via: 'get'

  match '/trending_searches/recent', to: 'trending_search#recent', via: 'get'
  
 match '/troll_candidates', to: 'troll_candidate#index', via: 'get'
end
