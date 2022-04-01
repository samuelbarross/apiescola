class PlanejamentoPedagogicoInfantil < ApplicationRecord
  belongs_to :serie
  belongs_to :ano_letivo

  audited on: [:update, :destroy] 

  has_one_attached :material

  validates :livro, :unidade, presence: true

  enum livro: {
    livro_I: 1,
    livro_II: 2,
    livro_III: 3,
    livro_IV: 4
  }

  enum unidade: {
    unidade_1: 1,
    unidade_2: 2,
    unidade_3: 3,
    unidade_4: 4,
    unidade_5: 5,
    unidade_6: 6,
    unidade_7: 7,
    unidade_8: 8,
    unidade_9: 9,
    unidade_10: 10,
    unidade_11: 11,
    unidade_12: 12
  }

end
