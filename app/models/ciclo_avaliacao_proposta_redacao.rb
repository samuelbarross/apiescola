class CicloAvaliacaoPropostaRedacao < ApplicationRecord
  belongs_to :ciclo_avaliacao
  belongs_to :serie

  has_many_attached :proposta_redacoes

  audited on: [:update, :destroy]  
end
