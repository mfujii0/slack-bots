Rails.application.routes.draw do
  resource :slack, only: :nil do
    post :sudden_death
    post :tsurai
    post :yoki
    post :xian
  end
  post :primitive_language, to: 'primitive_language#translate'
end
