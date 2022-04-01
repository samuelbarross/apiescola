class GestaoAvaliacaoPessoa < ApplicationRecord
  belongs_to :gestao_avaliacao
  belongs_to :pessoa

  has_many :gestao_avaliacao_questao_respostas, dependent: :destroy
  
  audited on: [:update, :destroy]
end
