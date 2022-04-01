class CicloAvaliacao < ApplicationRecord
  belongs_to :ano_letivo

  has_many :avaliacao_conhecimentos, dependent: :destroy
  has_many :ciclo_avaliacao_estruturas, dependent: :destroy
  has_many :ciclo_avaliacao_proposta_redacoes, dependent: :destroy
  has_many :ciclo_avaliacao_planejamentos, dependent: :destroy
  has_many :ciclo_avaliacao_escolas, dependent: :destroy
  has_many :ciclo_avaliacao_escola_agendamentos, dependent: :destroy
  has_many :acompanhamento_plano_acoes, dependent: :destroy

  audited on: [:update, :destroy]

  validates :descricao, :numero_referencia, presence: :true
end
