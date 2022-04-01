class Materia < ApplicationRecord
  belongs_to :area_conhecimento
  
  has_many :disciplinas, dependent: :destroy
  has_many :turma_avaliacao_resultados, dependent: :destroy
  has_many :objeto_conhecimento_materias, dependent: :destroy
  has_many :banco_questao_materias, dependent: :destroy
  has_many :avaliacao_conhecimento_estruturas, dependent: :destroy
  has_many :avaliacao_conhecimento_questoes, dependent: :destroy
  has_many :turma_valiacao_lista_adaptadas, dependent: :destroy
  has_many :turma_avaliacao_indice_proficiencias, dependent: :destroy
  has_many :avaliacao_conhecimento_validacoes
  has_many :tutoria_nivel_materias
  has_many :duvidas
  has_many :resultado_plano_acoes, dependent: :destroy
  
  audited on: [:update, :destroy]	

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado"]

  def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end	

  validates :area_conhecimento_id, :nome, :codigo, presence: true	
end
