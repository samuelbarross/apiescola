class AssuntoEdicao < ApplicationRecord
  belongs_to :ano_letivo
  belongs_to :assunto
  belongs_to :user, optional: true

  audited on: [:update, :destroy]

  enum status: {
    assunto_edicao_pendente: 1,
    assunto_edicao_liberado: 2
  }
end
