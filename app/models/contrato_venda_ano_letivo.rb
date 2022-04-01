class ContratoVendaAnoLetivo < ApplicationRecord
	belongs_to :contrato_venda
	belongs_to :ano_letivo
	has_many :contrato_venda_ano_letivo_etapas, dependent: :destroy
	has_many :contrato_venda_ano_letivo_series, dependent: :destroy

	audited on: [:update, :destroy]  

	validates :contrato_venda_id, :ano_letivo_id, presence: true
end
