class CapituloObjetoConhecimentoHabilidade < ApplicationRecord
  belongs_to :capitulo
  belongs_to :objeto_conhecimento_habilidade

  has_many :ciclo_avaliacao_planejamentos, dependent: :destroy
  
  audited on: [:update, :destroy]

  validates :ordem, presence: true
end
