Rails.application.routes.draw do
  root to: 'health#show'

  resource :slack, only: :nil do
    post :sudden_death
    post :tsurai
    post :yoki
    post :xian
  end
end
