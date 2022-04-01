class SerieAvaliacaoInfantil < ApplicationRecord
  belongs_to :ano_letivo, optional: true
  belongs_to :serie, optional: true
  belongs_to :campo_experiencia, optional: true
  belongs_to :sondagem_basica_desenvolvimento, optional: true
  belongs_to :avaliacao_conhecimento, optional: true
  has_many :serie_avaliacao_infantil_resultados

  audited on: [:update, :destroy]	
end
