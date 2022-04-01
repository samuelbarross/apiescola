class ObjetoConhecimentoHabilidade < ApplicationRecord
  belongs_to :objeto_conhecimento
  belongs_to :habilidade_oic

  has_many :capitulo_objeto_conhecimento_habilidades, dependent: :destroy
  has_many :banco_questoes, dependent: :destroy
  has_many :ia_plano_acao_oics, dependent: :destroy
  
  audited on: [:update, :destroy]

  validates :ordem, presence: true
end
