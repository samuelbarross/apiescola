class AvaliacaoConhecimentoEstrutura < ApplicationRecord
  belongs_to :avaliacao_conhecimento
  belongs_to :materia

  audited on: [:update, :destroy]

  validates :qtde_itens, presence: true
end
