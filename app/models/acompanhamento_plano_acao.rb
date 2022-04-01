class AcompanhamentoPlanoAcao < ApplicationRecord
  belongs_to :ciclo_avaliacao
  belongs_to :turma_avaliacao, optional: true
  belongs_to :pessoa
  belongs_to :turma_aluno, optional: true
  belongs_to :sede, optional: true
  belongs_to :serie, optional: true
  belongs_to :turma, optional: true

  audited on: [:update, :destroy]

  enum tipo: { 
    aluno: 1, 
    turma: 2,
    serie: 3,
    sede: 4,
    escola: 5
   }
end
