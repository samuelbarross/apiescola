class ResultadoPlanoAcao < ApplicationRecord
  belongs_to :turma_avaliacao_aluno, optional: true
  belongs_to :area_conhecimento, optional: true
  belongs_to :turma_avaliacao, optional: true
  belongs_to :turma_aluno, optional: true
  belongs_to :materia, optional: true

  audited on: [:update, :destroy]	

  enum tipo_registro: {
    resultado_aluno_area_conhecimento: 1,
    resultado_aluno_assunto: 2,
    resultado_aluno: 3,
    resultado_turma_area_conhecimento: 4,
    resultado_turma_assunto: 5,
    resultado_turma: 6,
    resultado_aluno_oic_habilidade: 7,
    resultado_turma_oic_habilidade: 8,
    resultado_aluno_materia: 9,   #criar rotina 
    resultado_turma_materia: 10   #criar rotina
  }
  
end
