class SondagemBasicaDesenvolvimento < ApplicationRecord
	has_many :serie_avaliacao_infantis, dependent: :destroy
	has_many :sondagem_basica_desenvolvimento_atividades, dependent: :destroy
	has_many :turma_avaliacao_resultados, dependent: :destroy
	has_many :objetivo_aprendizagem_desenvolvimentos, dependent: :destroy
	has_many :sondagem_basica_desenvolvimento_conteudo_digitais, dependent: :destroy

	has_one_attached :pdf_etapa_1
	has_one_attached :pdf_etapa_2
	has_one_attached :pdf_etapa_3
	has_one_attached :pdf_etapa_4
	
	accepts_nested_attributes_for :sondagem_basica_desenvolvimento_atividades, :allow_destroy => true
	accepts_nested_attributes_for :sondagem_basica_desenvolvimento_conteudo_digitais, :allow_destroy => true

	audited on: [:update, :destroy]	

	validates :nome, presence: true
end
