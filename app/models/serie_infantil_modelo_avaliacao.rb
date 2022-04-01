class SerieInfantilModeloAvaliacao < ApplicationRecord
  belongs_to :ano_letivo
  belongs_to :serie
  belongs_to :campo_experiencia
  belongs_to :sondagem_basica_desenvolvimento
  audited on: [:update, :destroy]
end
