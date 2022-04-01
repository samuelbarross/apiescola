class ContratoVendaAnoLetivoEtapa < ApplicationRecord
	belongs_to :contrato_venda_ano_letivo
  audited on: [:update, :destroy]	

	enum tipo: {
		medial_anual: 1,
		recuperacao: 2
	}

	validates :contrato_venda_ano_letivo_id, :tipo, :nome, :numero, presence: true
end
