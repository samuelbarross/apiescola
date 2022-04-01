class CampoExperienciaAtividade < ApplicationRecord
  belongs_to :campo_experiencia

  audited on: [:update, :destroy]	

  validates :campo_experiencia_id, :descricao, :destinado, :tipo, presence: true

  enum destinado: {
    destinado_professor: 1,
    destinado_pais: 2,
    destinado_aluno: 3
  }  

  enum tipo: {
    tipo_atividade_video: 1,
    tipo_atividade_plano_acao: 2
  }
end
