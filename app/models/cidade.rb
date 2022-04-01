class Cidade < ApplicationRecord
  belongs_to :estado
  has_many :cidades

  audited on: [:update, :destroy]
  
  UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at"]

  def self.ransackable_attributes auth_object = nil
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  validates :nome, :estado_id, :codigo_ibge, presence: true

end
