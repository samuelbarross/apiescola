class PlanejamentoPedagogicoTurma < ApplicationRecord
  belongs_to :assunto
  belongs_to :turma
  belongs_to :user
  belongs_to :planejamento_pedagogico_assunto
  belongs_to :user_confirmacao_aula, class_name: "User", foreign_key: :user_confirmacao_aula_id, optional: true

  has_many :turma_aluno_assuntos, dependent: :destroy

  audited on: [:update, :destroy]
end
