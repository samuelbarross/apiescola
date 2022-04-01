Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          get :sign_in, to: 'users#sign_in_user'
        end
      end

      resources :managers, only: %i[create]
      resources :evalution_inspections, only: %i[create]
    end
  end
end
