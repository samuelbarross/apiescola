class QuestionarioResposta < ApplicationRecord
  belongs_to :questionario_item, optional: true
  belongs_to :user

  audited on: [:update, :destroy]

  def descricao_qtde_palavras
    (self.descricao || '').split.count
  end
end
