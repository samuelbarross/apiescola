class AreaConhecimento < ApplicationRecord
	has_many :competencias, dependent: :destroy
	has_many :materias, dependent: :destroy
  has_many :turma_avaliacao_resultados, dependent: :destroy
  has_many :area_conhecimento_cursos, dependent: :destroy
  has_many :turma_avaliacao_lista_adaptadas, dependent: :destroy
  has_many :resultado_plano_acoes, dependent: :destroy
  has_many :avaliacao_conhecimento_questoes, dependent: :destroy
  has_many :avaliacao_conhecimento_questoes, dependent: :destroy
  has_many :ia_plano_acao_oics, dependent: :destroy
  has_many :turma_avaliacao_indice_proficiencias, dependent: :destroy
  has_many :avaliacao_conhecimento_validacoes

  accepts_nested_attributes_for :area_conhecimento_cursos, :allow_destroy => true

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado"]

  def self.ransackable_attributes auth_object = nil
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  validates :nome, :codigo, presence: true
  audited on: [:update, :destroy]

  def classe_panel_color
    case self.codigo
    when 'A04'  #Linguagens
      'primary'
    when 'A01'  #Humanas
      'success'
    when 'A02'  #Natureza
      'info'
    when 'A05'  #Matemática
      'warning'
    when 'A03'  #Redação
      'danger'
    end
  end
end
