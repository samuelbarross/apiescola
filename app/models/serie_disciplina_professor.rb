class SerieDisciplinaProfessor < ApplicationRecord
	belongs_to :contrato_venda_ano_letivo_serie
	belongs_to :serie_disciplina
	belongs_to :pessoa_professor
  audited on: [:update, :destroy]	
end
