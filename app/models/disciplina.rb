class Disciplina < ApplicationRecord
	belongs_to :materia

	has_many :capitulos, dependent: :destroy
	has_many :conteudo_programatico_padroes, dependent: :destroy
	has_many :serie_disciplinas, dependent: :destroy
	has_many :tuma_professores, dependent: :destroy
	has_many :avaliacao_conhecimentos, dependent: :destroy
	has_many :avaliacao_conhecimento_questoes, dependent: :destroy
	has_many :turma_avaliacao_resultados, dependent: :destroy
	has_many :assuntos, dependent: :destroy
	has_many :turma_avaliacao_lista_adaptdas, dependent: :destroy
	has_many :planejamento_pedagogicos, dependent: :destroy
	has_many :sistema_ensino_disciplinas, dependent: :destroy
	has_many :turma_avaliacao_indice_proficiencias, dependent: :destroy

	# after_save :atualizar_nome_migracao_planilha

	audited on: [:update, :destroy]	

	accepts_nested_attributes_for :assuntos, :allow_destroy => true
	accepts_nested_attributes_for :serie_disciplinas, :allow_destroy => true

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado"]

  def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  validates :nome, :codigo, :materia_id, presence: true

	def atualizar_nome_migracao_planilha
		self.update(nome_migracao_planilha: Diversos.remover_acentos(self.nome).upcase )
	end
end
