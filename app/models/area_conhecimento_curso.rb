class AreaConhecimentoCurso < ApplicationRecord
  belongs_to :area_conhecimento
  belongs_to :curso

  audited on: [:update, :destroy]
end
