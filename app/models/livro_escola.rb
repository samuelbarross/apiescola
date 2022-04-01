class LivroEscola < ApplicationRecord
  belongs_to :livro
  belongs_to :pessoa

  audited on: [:update, :destroy]
end
