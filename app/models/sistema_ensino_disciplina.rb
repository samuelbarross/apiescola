class SistemaEnsinoDisciplina < ApplicationRecord
  belongs_to :sistema_ensino
  belongs_to :disciplina

  audited on: [:update, :destroy]
end
