class PlanejamentoPedagogicoAssunto < ApplicationRecord
  belongs_to :planejamento_pedagogico
  belongs_to :assunto

  has_many :planejamento_pedagogico_turmas, dependent: :destroy

  audited on: [:update, :destroy] 
end
