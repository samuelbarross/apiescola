class CicloAvaliacaoEstrutura < ApplicationRecord
  belongs_to :ciclo_avaliacao
  belongs_to :serie
  belongs_to :materia

  audited on: [:update, :destroy]  
end
