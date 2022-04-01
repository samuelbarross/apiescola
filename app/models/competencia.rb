class Competencia < ApplicationRecord
	belongs_to :area_conhecimento
  has_many :habilidades, dependent: :destroy
  has_many :turma_avaliacao_resultados, dependent: :destroy
  
  audited on: [:update, :destroy]
    
	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado"]

  def self.ransackable_attributes auth_object = nil
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end	

  validates :area_conhecimento_id, :nome, :codigo, presence: true
end
