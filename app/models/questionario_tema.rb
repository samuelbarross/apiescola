class QuestionarioTema < ApplicationRecord
  audited on: [:update, :destroy]

  has_many :questionario_itens, dependent: :destroy
  has_many :questionario_respostas, dependent: :destroy

  accepts_nested_attributes_for :questionario_itens, :allow_destroy => true
end
