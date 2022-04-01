class AnoLetivo < ApplicationRecord
	has_many :serie_disciplinas, dependent: :destroy
	has_many :conteudo_programatico_padroes, dependent: :destroy
	has_many :contrato_venda_ano_letivos, dependent: :destroy
	has_many :users, dependent: :destroy
	has_many :turmas, dependent: :destroy
	has_many :avaliacao_conhecimentos, dependent: :destroy
	has_many :serie_avaliacao_infantis, dependent: :destroy
	has_many :assunto_sistema_ensinos, dependent: :destroy
	has_many :migracao_planilhas, dependent: :destroy
	has_many :planejamento_pedagogicos, dependent: :destroy
	has_many :configuracoes, dependent: :destroy
	has_many :ecommerce_ano_letivos, class_name: "Configuracao", foreign_key: :ecommerce_ano_letivo_id, dependent: :destroy
	has_many :escola_material_didaticos, dependent: :destroy
	has_many :pedido_vendas

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at"]

	def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
	end

	audited on: [:update, :destroy]
end
