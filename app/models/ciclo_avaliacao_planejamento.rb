class CicloAvaliacaoPlanejamento < ApplicationRecord
  belongs_to :ciclo_avaliacao
  belongs_to :objeto_conhecimento
  belongs_to :habilidade_oic
  belongs_to :objeto_conhecimento_habilidade
  belongs_to :user, optional: true
  belongs_to :materia, optional: true
  belongs_to :disciplina, optional: true
  belongs_to :area_conhecimento, optional: true

  audited on: [:update, :destroy]

end
