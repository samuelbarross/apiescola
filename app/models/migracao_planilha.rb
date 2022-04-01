class MigracaoPlanilha < ApplicationRecord
  belongs_to :ano_letivo
  belongs_to :pessoa
  belongs_to :user

  has_many :migracao_planilha_itens, dependent: :destroy

  has_one_attached :planilha

  validates :ano_letivo_id, :pessoa_id, :tipo_migracao, presence: true

  enum tipo_migracao: {
    tipo_migracao_aluno: 1,
    tipo_migracao_professor: 2,
    tipo_migracao_apg: 3
  }
  
  enum versao: {
    versao_1: 1,
    versao_2: 2
  }
end
