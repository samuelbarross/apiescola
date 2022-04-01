class AvaliacaoConhecimentoValidacao < ApplicationRecord
  belongs_to :avaliacao_conhecimento
  belongs_to :area_conhecimento
  belongs_to :materia
  belongs_to :user

  audited on: [:update, :destroy]
end
