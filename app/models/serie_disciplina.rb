class SerieDisciplina < ApplicationRecord
	belongs_to :ano_letivo
	belongs_to :serie
	belongs_to :disciplina
	belongs_to :sistema_ensino
	
	has_many :serie_disciplina_professores, dependent: :destroy
	has_many :planejamento_pedagogicos, dependent: :destroy

	audited on: [:update, :destroy] 
	
	validates :ano_letivo_id, :serie_id, :disciplina_id, presence: true
end
