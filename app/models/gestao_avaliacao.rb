class GestaoAvaliacao < ApplicationRecord
  belongs_to :avaliacao_conhecimento
  belongs_to :avaliacao_conhecimento_escola

	has_many :gestao_avaliacao_pessoas, dependent: :destroy
	has_many :gestao_avaliacao_questao_respostas, dependent: :destroy

  audited on: [:update, :destroy]	

	enum status: {
		aguardando_processamento: 1,
		processando_resultado: 2,
		concluido: 3,
		falhou: 4,
		liberado: 5,
		nao_aplicar: 6
  }
	
	accepts_nested_attributes_for :gestao_avaliacao_pessoas, :allow_destroy => true
end
