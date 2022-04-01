class ConteudoProgramaticoPadrao < ApplicationRecord
	belongs_to :ano_letivo
	belongs_to :disciplina
	belongs_to :serie
	has_many :conteudo_programtico_padrao_capitulos, dependent: :destroy

  audited on: [:update, :destroy]

  validates :ano_letivo_id, :disciplina_id, :nome, :serie_id, presence: true

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado", "disciplina_id", "serie_id", "ano_letivo_id"]

  def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  validates :ano_letivo_id, :disciplina_id, :serie_id, presence: true    
end
