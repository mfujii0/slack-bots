Rails.application.routes.draw do
  resource :slack, only: :nil do
    post :sudden_death
    post :tsurai
    post :yoki
  end
end
