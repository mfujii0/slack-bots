Rails.application.routes.draw do
  resource :slack, only: :nil do
    post :sudden_death
  end
end
