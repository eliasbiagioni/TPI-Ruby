Rails.application.routes.draw do
  resources :users, only: :create
  post 'sessions', to: 'authentication#authenticate'
  put 'questions/:id/resolve', to: 'questions#resolve'
  resources :questions do
  		get :answers,  to: 'questions#questions_answers'
  		post :answers, to: 'questions#new_answer'
		delete :answers, path: 'answers/:answer_id', to: 'questions#delete_answer'
  end
end
