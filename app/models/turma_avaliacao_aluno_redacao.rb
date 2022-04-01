class TurmaAvaliacaoAlunoRedacao < ApplicationRecord
  belongs_to :turma_avaliacao_aluno
  belongs_to :user

  audited on: [:update, :destroy]	

end
