class IaPlanoAcaoOic < ApplicationRecord
  belongs_to :objeto_conhecimento
  belongs_to :habilidade_oic
  belongs_to :objeto_conhecimento_habilidade
  belongs_to :area_conhecimento
  belongs_to :avaliacao_conhecimento_questao

  has_many :ia_plano_acao_itens, dependent: :destroy

  audited on: [:update, :destroy]	
end
