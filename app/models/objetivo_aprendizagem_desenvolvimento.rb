class ObjetivoAprendizagemDesenvolvimento < ApplicationRecord
  belongs_to :campo_experiencia
  belongs_to :sondagem_basica_desenvolvimento
  
  audited on: [:update, :destroy]	

  # validates :descricao, presence: true

  enum faixa_etaria: {
    bebe: 1,
    crianca_bem_pequena: 2,
    crianca_pequena: 3
  }
end
