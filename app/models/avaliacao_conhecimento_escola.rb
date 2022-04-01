class AvaliacaoConhecimentoEscola < ApplicationRecord
  belongs_to :avaliacao_conhecimento
  belongs_to :user
  belongs_to :pessoa_escola, class_name: 'Pessoa', foreign_key: :pessoa_escola_id

  has_many :gestao_avaliacoes, dependent: :destroy

  audited on: [:update, :destroy]	
  
	has_one_attached :planilha_tri_linguagens
	has_one_attached :planilha_tri_humanas
	has_one_attached :planilha_tri_natureza
	has_one_attached :planilha_tri_matematica
	has_one_attached :planilha_tri_linguagens_pa
	has_one_attached :planilha_tri_humanas_pa
	has_one_attached :planilha_tri_natureza_pa
  has_one_attached :planilha_tri_matematica_pa
  
  enum situacao: {
    recebida: 1,
    aceita: 2,
    aplicada: 3,
    liberada_svida: 4
  }
end
