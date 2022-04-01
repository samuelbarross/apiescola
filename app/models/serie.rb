class Serie < ApplicationRecord
	belongs_to :nivel

	has_many :serie_disciplinas, dependent: :destroy
	has_many :conteudo_programatico_padroes, dependent: :destroy
	has_many :contrato_venda_ano_letivo_series, dependent: :destroy
	has_many :turmas, dependent: :destroy
	has_many :avaliacao_conhecimentos, dependent: :destroy
	has_many :serie_avaliacao_infantis, dependent: :destroy
	has_many :planejamento_pedagogicos, dependent: :destroy
	has_many :livros, dependent: :destroy
	has_many :serie_coordenacoes, dependent: :destroy
	has_many :planejamento_pedagogico_infantis, dependent: :destroy
	has_many :produtos, dependent: :destroy
	has_many :pedido_vendas, dependent: :destroy
	has_many :conteudo_digital_series, dependent: :destroy
	has_many :ciclo_avaliacao_proposta_redacoes, dependent: :destroy
	has_many :ciclo_avaliacao_escola_agendamentos, dependent: :destroy
	has_many :escola_material_didaticos, dependent: :destroy
	has_many :proposta_redacoes, dependent: :destroy
	has_many :duvidas, dependent: :destroy
	
  audited on: [:update, :destroy]	

	accepts_nested_attributes_for :serie_disciplinas, :allow_destroy => true

	accepts_nested_attributes_for :serie_avaliacao_infantis, :allow_destroy => true
		
	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "id_legado"]

	def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
	end

	validates :nome, :codigo, :nivel_id, :ordem, presence: true	

	def materias
		return self.serie_disciplinas
								.joins('inner join disciplinas d on (serie_disciplinas.disciplina_id = d.id)')
								.joins('inner join materias m on (d.materia_id = m.id)')
								.pluck('m.id').uniq
	end
end
