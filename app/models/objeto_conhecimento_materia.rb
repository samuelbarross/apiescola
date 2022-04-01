class ObjetoConhecimentoMateria < ApplicationRecord
  belongs_to :objeto_conhecimento
  belongs_to :materia

  audited on: [:update, :destroy]
end
