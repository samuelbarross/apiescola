class SerieCoordenacao < ApplicationRecord
  belongs_to :pessoa
  belongs_to :serie
  belongs_to :pessoa_escola, class_name: "Pessoa", foreign_key:"pessoa_escola_id", optional: true

  audited on: [:update, :destroy]

  validates :pessoa_id, :pessoa_escola_id, :serie_id, presence: true
end
