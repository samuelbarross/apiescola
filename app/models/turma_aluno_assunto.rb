class TurmaAlunoAssunto < ApplicationRecord
  belongs_to :planejamento_pedagogico_turma
  belongs_to :turma_aluno
  belongs_to :assunto

  has_many :turma_aluno_assunto_questoes, dependent: :destroy

  audited on: [:update, :destroy]	

end
