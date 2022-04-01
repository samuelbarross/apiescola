class EscolaMaterialDidatico < ApplicationRecord
  belongs_to :pessoa
  belongs_to :serie
  belongs_to :ano_letivo
  belongs_to :livro
  belongs_to :user

  audited on: [:update, :destroy]

  
end
