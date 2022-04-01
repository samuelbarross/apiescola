class Boletim < ApplicationRecord
	belongs_to :turma_aluno
	belongs_to :materia
	belongs_to :disciplina
	belongs_to :contrato_venda_ano_letivo_etapa
  
  audited on: [:update, :destroy]  

	validates :turma_aluno_id, :materia_id, :disciplina_id, :contrato_venda_ano_letivo_etapa_id, presence: true
end
