class ContratoVendaAnoLetivoSerie < ApplicationRecord
	belongs_to :contrato_venda_ano_letivo
	belongs_to :serie
	has_many :serie_disciplina_professores, dependent: :destroy
	has_many :turmas, dependent: :destroy

	audited on: [:update, :destroy]

	validates :contrato_venda_ano_letivo_id, :serie_id, presence: true
end
