class TurmaProfessor < ApplicationRecord
  belongs_to :turma
  belongs_to :disciplina, optional: true
  belongs_to :pessoa_professor, class_name: "Pessoa", foreign_key: :pessoa_professor_id

  audited on: [:update, :destroy]	

  enum status: {
		ativo: 1,
		inativo: 2
  }
  
end
