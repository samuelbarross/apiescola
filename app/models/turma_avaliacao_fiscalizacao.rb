class TurmaAvaliacaoFiscalizacao < ApplicationRecord
  belongs_to :turma_avaliacao
  belongs_to :turma_aluno

  enum tipo_registro: {saida: 1, entrada: 2}
end
