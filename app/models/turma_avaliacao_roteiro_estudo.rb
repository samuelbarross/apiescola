class TurmaAvaliacaoRoteiroEstudo < ApplicationRecord
  belongs_to :turma_avaliacao
  belongs_to :avaliacao_conhecimento_questao
  belongs_to :turma_avaliacao_aluno
  belongs_to :turma_aluno

  audited on: [:update, :destroy]

  enum nivel: { 
    critico: 1, 
    baixo: 2,
    medio: 3,
    alto: 4,
    elevado: 5
  }

end
