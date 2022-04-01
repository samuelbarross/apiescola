class IaPlanoAcao < ApplicationRecord
  belongs_to :turma_avaliacao
  belongs_to :turma_avaliacao_aluno
  belongs_to :turma_aluno

  has_many :ia_plano_acao_oics, dependent: :destroy
  has_many :ia_plano_acao_itens, dependent: :destroy

  audited on: [:update, :destroy]	
end
