class TurmaAlunoIndiceProficiencia < ApplicationRecord
  belongs_to :turma_aluno
  belongs_to :area_conhecimento, optional: true
  belongs_to :materia, optional: true
  belongs_to :disciplina, optional: true

  audited on: [:update, :destroy]

  enum tipo: { 
    tipo_geral: 1,
    tipo_area: 2, 
    tipo_materia: 3,
    tipo_disciplina: 4
  }  
end
