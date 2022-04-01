class TurmaAvaliacaoMarcacao < ApplicationRecord
  belongs_to :turma_avaliacao
  belongs_to :turma_aluno
  audited on: [:update, :destroy]
end
