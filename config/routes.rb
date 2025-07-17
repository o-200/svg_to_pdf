Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pdf_documents#index"

  post "pdf_documents/create", to: "pdf_documents#create"
  get "pdf_documents/show", to: "pdf_documents#show"
end
