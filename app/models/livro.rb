class Livro < ApplicationRecord
  belongs_to :serie
  belongs_to :sistema_ensino, optional: true

  has_many :capitulos, dependent: :destroy
  has_many :livro_escolas, dependent: :destroy
  has_many :escola_material_didaticos, dependent: :destroy  
  
  has_one_attached :livro
  has_one_attached :capa_livro
  has_one_attached :planilha_capitulos

  validates :titulo, :descricao, presence: true	

  audited on: [:update, :destroy]
end
