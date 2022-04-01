class ConteudoProgramaticoPadraoCapitulo < ApplicationRecord
	belongs_to :conteudo_programatico_padrao
	belongs_to :capitulo

	audited on: [:update, :destroy]  

	validates :conteudo_programatico_padrao_id, :capitulo_id, presence: true
end
