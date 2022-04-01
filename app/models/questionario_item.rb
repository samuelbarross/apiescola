class QuestionarioItem < ApplicationRecord
  belongs_to :questionario_tema

  has_many :questionario_respostas, dependent: :destroy
  
  audited on: [:update, :destroy]
end
