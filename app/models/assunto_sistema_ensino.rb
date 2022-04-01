class AssuntoSistemaEnsino < ApplicationRecord
  belongs_to :ano_letivo
  belongs_to :assunto
  belongs_to :user, optional: true

  audited on: [:update, :destroy]

  validates :ano_letivo_id, :assunto_id, :sistema_ensino, presence: true

  enum sistema_ensino: {
    sistema_ensino_svida: 1,
    sistema_ensino_sas: 2
  }

end
