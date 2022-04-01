class EscolaProduto < ApplicationRecord
  belongs_to :pessoa, optional: true
  belongs_to :produto
  belongs_to :user
  belongs_to :condicao_pagamento

  audited on: [:update, :destroy]

  validates :valor, :valor_svida, :data_vigencia, presence: true

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "pessoa_id", "produto_id", "user_id"]

	def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
	end    
end
