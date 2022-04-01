class Turma < ApplicationRecord
	belongs_to :contrato_venda_ano_letivo_serie
	belongs_to :pessoa_escola, class_name: "Pessoa", foreign_key: :pessoa_escola_id, optional: true
	belongs_to :ano_letivo, optional: true
	belongs_to :serie, optional: true
	belongs_to :nivel, optional: true
	belongs_to :sede, optional: true
	belongs_to :sistema_ensino, optional: true

	has_many :turma_alunos, dependent: :destroy
	has_many :turma_avaliacoes, dependent: :destroy
	has_many :turma_professores, dependent: :destroy
	has_many :planejamento_pedagogico_turmas, dependent: :destroy
	has_many :convite_pessoas, dependent: :destroy
	has_many :ciclo_avaliacao_escola_agendamentos, dependent: :destroy
	has_many :ciclo_avaliacao_planejamentos, dependent: :destroy

	audited on: [:update, :destroy]	
	
	after_create :atualizar_referencia

  accepts_nested_attributes_for :turma_alunos, :allow_destroy => true
	accepts_nested_attributes_for :turma_professores, :allow_destroy => true

	UNRANSACKABLE_ATTRIBUTES = ["contrato_venda_ano_letivo_serie_id", "created_at", "updated_at", "id_legado", "ano_letivo_id", "pessoa_escola_id"]

	validates :contrato_venda_ano_letivo_serie_id, :codigo, :turno, :sede_id, presence: true

  def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end	

	enum turno: {
		manha: 1,
		tarde: 2,
		noite: 3,
		integral: 4
	}

	enum status: {
		ativo: 1,
		inativo: 2
	}

	def atualizar_referencia
		self.update(
			pessoa_escola_id: self.contrato_venda_ano_letivo_serie.contrato_venda_ano_letivo.contrato_venda.pessoa_escola_id,
			ano_letivo_id: self.contrato_venda_ano_letivo_serie.contrato_venda_ano_letivo.ano_letivo_id,
			serie_id: self.contrato_venda_ano_letivo_serie.serie_id,
			nivel_id: self.contrato_venda_ano_letivo_serie.serie.nivel_id
		)
		self.save
	end

	def nome_completo_com_escola
		nome_completo = self.serie.nome + ' - ' + self.codigo + ' - ' + (self.turno.nil? ? '' : self.turno_i18n) + ' - ' + self.serie.nivel.nome + ' - ' + self.pessoa_escola.nome + ' - ' + self.sede.nome
	end

	def nome_completo_sem_escola
		nome_completo = self.serie.nome + ' - ' + self.codigo + ' - ' + (self.turno.nil? ? '' : self.turno_i18n) + ' - ' + self.serie.nivel.nome + ' - ' + self.sede.nome
	end

	def nome_sem_escola_v2
		self.serie.nome + ' | ' + self.codigo + ' | ' + (self.turno.nil? ? '' : self.turno_i18n) + ' | ' + self.serie.nivel.nome + ' | ' + (self.pessoa_escola.nome_fantasia || self.pessoa_escola.nome) + ' | ' + self.ano_letivo.ano.to_s
	end

	def nome_sede_escola_v2
		self.sede.nome
	end

	def quantidade_aluno_ativo
		self.turma_alunos.where(status: 1).count
	end

	def quantidade_aluno_laudado
		self.turma_alunos.joins(:aluno).where(pessoas: {laudado: true}).where(status: 1).count
	end

	def tipo_operacao_contrato_comercial
		self.contrato_venda_ano_letivo_serie.contrato_venda_ano_letivo.contrato_venda.tipo_operacao_i18n
	end

	def resumo_ciclos_infantil
		
	end

	def materias(_ano_letivo_id)
		Materia.where(id: self.serie.serie_disciplinas.joins(:disciplina).where(ano_letivo_id: _ano_letivo_id).pluck(:'disciplinas.materia_id').uniq).where(disponivel_tira_duvida: true)
	end

	def ciclos(user)   #, _tipo) 
		turma_avaliacoes = self.turma_avaliacoes.where.not(status: 10)
		
		turma_avaliacoes = self.turma_avaliacoes.where('turma_avaliacoes.data_aplicacao <= ?', Time.zone.now).where(status: :liberado) if ['aluno'].include?(user.perfil)

		unless self.nivel.codigo.eql? ('EI')  #tipo.eql? ('itens')
			turma_avaliacoes = turma_avaliacoes.joins(:avaliacao_conhecimento).where(avaliacao_conhecimentos: {versao: AvaliacaoConhecimento.versoes[:versao_2]})
		else
			turma_avaliacoes = turma_avaliacoes.joins(:avaliacao_conhecimento).where(avaliacao_conhecimentos: {modelo: AvaliacaoConhecimento.modelos[:sondagem]})
		end

		turma_avaliacoes.pluck(:id).uniq
	end	

end



