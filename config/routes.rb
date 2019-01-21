Rails.application.routes.draw do
  resources :users, :answers, :questions
  post 'sessions', to: 'authentication#authenticate'
  put 'questions/:id/resolve', to: 'questions#resolve'
  get 'questions/:question_id/answers', to: 'questions#questions_answers'
  post 'questions/:question_id/answers', to: 'questions#new_answer'
  delete 'questions/:question_id/answers/:answer_id', to: 'questions#delete_answer'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
