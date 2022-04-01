class CursoNotaCorte < ApplicationRecord
  belongs_to :curso
  belongs_to :pessoa
  audited on: [:update, :destroy]

end
