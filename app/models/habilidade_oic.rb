class HabilidadeOic < ApplicationRecord
  audited on: [:update, :destroy]

  belongs_to :bloom_taxonomia

  has_many :objeto_conhecimento_habilidades, dependent: :destroy
  has_many :ciclo_avaliacao_planejamentos, dependent: :destroy
  has_many :ia_plano_acao_oics, dependent: :destroy
  
  validates :descricao, presence: true

end
