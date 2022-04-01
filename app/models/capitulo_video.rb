class CapituloVideo < ApplicationRecord
  belongs_to :capitulo

  audited on: [:update, :destroy]
end
