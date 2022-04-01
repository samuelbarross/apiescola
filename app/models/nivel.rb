class Nivel < ApplicationRecord
  has_many :series, dependent: :destroy
  has_many :turmas, dependent: :destroy
  has_many :tutoria_nivel_materias
  
  audited on: [:update, :destroy]	

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado"]

  def self.ransackable_attributes auth_object = nil
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  validates :nome, :codigo, :ordem, presence: true
end
