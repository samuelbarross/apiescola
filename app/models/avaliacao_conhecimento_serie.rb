class AvaliacaoConhecimentoSerie < ApplicationRecord
  belongs_to :avaliacao_conhecimento
  belongs_to :serie

  audited on: [:update, :destroy]
end
