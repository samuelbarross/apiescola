class Estado < ApplicationRecord
	has_many :cidades, dependent: :destroy
  audited on: [:update, :destroy]	

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado"]

  def self.ransackable_attributes auth_object = nil
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end	

  validates :nome, :codigo_ibge, :sigla, presence: true

  audited on: [:update, :destroy]
end
