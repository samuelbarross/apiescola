class TurmaAvaliacaoAcompanhamento < ApplicationRecord
  belongs_to :turma_avaliacao
  belongs_to :turma
  belongs_to :pessoa_escola, class_name: "Pessoa", foreign_key: :pessoa_escola_id, optional: true

  audited on: [:update, :destroy]

  enum situacao: {
    no_prazo: 1,
    atrasado: 2
  }
end
