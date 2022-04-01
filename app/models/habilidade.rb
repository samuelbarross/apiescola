class Habilidade < ApplicationRecord
  belongs_to :competencia
  belongs_to :bloom_taxonomia, optional: true
  has_many :banco_questoes, dependent: :destroy
  has_many :avaliacao_conhecimento_questoes, dependent: :destroy
  has_many :turma_avaliacao_resultados, dependent: :destroy
    
  audited on: [:update, :destroy]	

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado"]

  def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end	

  validates :competencia_id, :nome, :codigo, presence: true

end
