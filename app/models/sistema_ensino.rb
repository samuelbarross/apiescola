class SistemaEnsino < ApplicationRecord
  has_many :livros, dependent: :destroy
  has_many :turmas, dependent: :destroy
  has_many :serie_disciplinas, dependent: :destroy
  has_many :sistema_ensino_disciplinas, dependent: :destroy
  
  audited on: [:update, :destroy]

  accepts_nested_attributes_for :sistema_ensino_disciplinas, :allow_destroy => true
end
