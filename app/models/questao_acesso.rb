class QuestaoAcesso < ApplicationRecord
  belongs_to :avaliacao_conhecimento_questao
  belongs_to :turma_aluno
  belongs_to :turma_avaliacao_lista_adaptada
  audited on: [:update, :destroy]
end
