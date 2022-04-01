class EdicaoEstilo < ApplicationRecord
  audited on: [:update, :destroy]	

  validates :nome, presence: true

  has_one_attached :imagem_estilo
end
