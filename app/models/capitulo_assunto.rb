class CapituloAssunto < ApplicationRecord
  belongs_to :capitulo
  belongs_to :assunto

  audited on: [:update, :destroy]
  validates :capitulo_id, :descricao, presence: true  

end
