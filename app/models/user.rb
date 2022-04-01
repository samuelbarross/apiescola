class User < ApplicationRecord
	acts_as_token_authenticatable

	belongs_to :ano_letivo, optional: true
	belongs_to :pessoa, optional: true
	belongs_to :user_pessoa, class_name: "Pessoa", foreign_key: :pessoa_escola_id, optional: true

	has_many :avaliacao_conhecimento_escolas, dependent: :destroy
	has_many :assunto_sistema_ensinos, dependent: :destroy
	has_many :migracao_planilhas, dependent: :destroy
	has_many :turma_avaliacao_aluno_redacoes, dependent: :destroy
	has_many :user_nota_redacoes, class_name: "TurmaAvaliacaoAluno", foreign_key: :user_nota_redacao_id, dependent: :destroy
	has_many :user_confirmacao_aulas, class_name: "PlanejamentoPedagogicoTurma", foreign_key: :user_confirmacao_aula_id, dependent: :destroy
	has_many :registro_navegacoes, dependent: :destroy
	has_many :escola_produtos, dependent: :destroy
	has_many :pedido_vendas, dependent: :destroy
	has_many :user_confirmacao_manual_pedido_venda_pagamentos, class_name: "PedidoVendaPagamento", foreign_key: :user_confirmacao_manual_id, dependent: :destroy
	has_many :copom_descontos, dependent: :destroy
	has_many :banco_questao_revisoes, dependent: :destroy
	has_many :ciclo_avaliacao_escola_agendamento_user_liberacoes, class_name: "CicloAvaliacaoEscolaAgendamento", foreign_key: :user_liberacao_id, dependent: :destroy
	has_many :escola_material_didaticos, dependent: :destroy
	has_many :questionario_respostas, dependent: :destroy
	has_many :avaliacao_conhecimento_validacoes
	has_many :tutoria_nivel_materias
	has_many :duvida_mensagens
	has_many :user_nota_professor, class_name: "AvaliacaoConhecimentoQuestaoSugestao", foreign_key: :user_nota_professor_id
	has_many :pacote_servicos

	devise :database_authenticatable, :registerable,
				:recoverable, :rememberable,
				:validatable, authentication_keys: [:login]

	audited on: [:update, :destroy]

	attr_accessor :login
	attr_writer :login

	validates :email, presence: true, if: :email_required?
	validates :username, presence: :true, uniqueness: { case_sensitive: false }, if: :usuario_monitorado?
	validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
	validate :validate_username

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "encrypted_password", "reset_password_token", "reset_password_sent_at", "remember_created_at", "first_name", "last_name", "sexo", "ano_letivo_id", "pessoa_id", "pessoa_escola_id",
		"perfil", "speck_id", "inactive"]

	def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
	end



	enum sexo: {
		masculino: 1,
		feminino: 2,
		sexo_ignorado: 3
	}

	enum perfil: {
		gestao_vida: 1,
		aluno: 2,
		professor: 3,
		gestao_escola: 4,
		pais: 5,
		vendedor: 6,
		diretor: 7,
		coordenador: 8,
		supervisor: 9,
		apresentacao: 10,
		escola_online: 11,
		ecommerce: 12,
		admin: 13,
		psicologo: 14,
		prospeccao: 15
	}

	def minhas_escolas
		self.pessoa.pessoa_escolas.pluck(:pessoa_escola_id)
	end

  def login
		@login || self.username || self.email
	end

	def email_required?
		self.username.nil?
	end

	def self.find_first_by_auth_conditions(warden_conditions)
		conditions = warden_conditions.dup
		
		if login = conditions.delete(:login)
			where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
		else
			if conditions[:username].nil?
				where(conditions).first
			else
				where(username: conditions[:username]).first
			end
		end
	end

	# def self.find_first_by_auth_conditions(warden_conditions)
	# 	conditions = warden_conditions.dup
		
	# 	if login == conditions.delete(:login)
	# 		where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
	# 	else
	# 		if conditions[:username].nil?
	# 			where(conditions).first
	# 		else
	# 			where(username: conditions[:username]).first
	# 		end
	# 	end
	# end

	# def self.find_for_database_authentication(warden_conditions)
	# 	conditions = warden_conditions.dup

	# 	if login = conditions.delete(:login)
	# 		where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
	# 	elsif conditions.has_key?(:username) || conditions.has_key?(:email)
	# 		where(conditions.to_h).first
	# 	end
	# end


	def validate_username
		unless self.perfil.eql?('ecommerce')
			if User.where(username: username).where.not(id: self.id).exists?
				errors.add(:username, :invalid)
			else
				true
			end
		else
			true
		end
	end

	def active_for_authentication?
		!self.inactive
	end

	def inactive_message
		:account_inactive
	end

	def usuario_monitorado?
		if self.perfil.nil?
			self.perfil = :ecommerce
			false
		elsif self.perfil.eql?('ecommerce')
			false
		else
			true
		end
	end

	def questionario_prospeccao_qtde_palavras
		_qtde_palavras_digitada = 0
		_percentual_digitado = 0
   	self.questionario_respostas.each do |questionario_resposta|
			_qtde_palavras_digitada += (questionario_resposta.descricao || '').split.count
		end

    _qtde_palavras_parametro = Parametro.find_by_numero(3).conteudo_inteiro

		if _qtde_palavras_parametro > 0 
			if _qtde_palavras_digitada < _qtde_palavras_parametro
				_percentual_digitado = (_qtde_palavras_digitada.to_f / _qtde_palavras_parametro.to_f * 100.0).round(2) 
			else
				_percentual_digitado = 100
			end
		end

		return { qtde_palavras_digitada: _qtde_palavras_digitada, qtde_palavras_parametro: _qtde_palavras_parametro, percentual_digitado: _percentual_digitado }
  end

	def nome_ux_maxia
		(self.pessoa.nome_fantasia.empty? ? self.pessoa.nome : self.pessoa.nome_fantasia).split(' ')[0]
	end

	def letra_ux_maxia
		self.nome_ux_maxia[0]		
	end

	def class_model_avatar
		case self.model_avatar
		when 1
			'bg-roxo'
		when 2
			'bg-azul'
		when 3
			'bg-rosa'
		when 4
			'bg-preto'
		when 5
			'bg-cinza'
		end
	end

	def informacao_pacote_servico(_servico)
		_qtde_itens_pacote = 0
		_qtde_itens_acumulado = 0
		_qtde_itens_restantes = 0
		_valor = 0.00
		_pc = 0
		_descricao = 'questões'

		pacote_servico_preco = PacoteServicoPreco.where(servico: _servico).where(data_vigencia: PacoteServicoPreco.where(servico: _servico).where('data_vigencia <= ?', Date.today).maximum(:data_vigencia)).first
		if pacote_servico_preco.present?
			_qtde_itens_pacote = pacote_servico_preco.qtde_itens
			_valor = pacote_servico_preco.valor.to_f

			pacote_servico = self.pacote_servicos.where(data_fechamento: nil).first
			if pacote_servico.present?
				_qtde_itens_acumulado = pacote_servico.pacote_servico_itens.count
				_qtde_itens_restantes = pacote_servico_preco.qtde_itens - pacote_servico.pacote_servico_itens.count
				_descricao = (_qtde_itens_restantes > 1 ?  'questões' : 'questão')
				_pc = (pacote_servico.pacote_servico_itens.count.fdiv(pacote_servico_preco.qtde_itens) * 100.0).to_f.to_i if pacote_servico_preco.qtde_itens > 0
			else
				_qtde_itens_restantes = pacote_servico_preco.qtde_itens
			end
		end

		return {qtde_itens_pacote: _qtde_itens_pacote, qtde_itens_acumulado: _qtde_itens_acumulado, qtde_itens_restantes: _qtde_itens_restantes, valor: _valor, percentual: _pc, descricao: _descricao}
	end	

	protected

	def self.send_reset_password_instructions attributes = {}		
		recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
		recoverable.send_reset_password_instructions if recoverable.persisted?
		recoverable
	end

	def self.find_recoverable_or_initialize_with_errors required_attributes, attributes, error = :invalid
		(case_insensitive_keys || []).each {|k| attributes[k].try(:downcase!)}

		attributes = attributes.slice(*required_attributes)
		attributes.delete_if {|_key, value| value.blank?}

		if attributes.keys.size == required_attributes.size
			if attributes.key?(:login)
				login = attributes.delete(:login)
				record = find_record(login)
			else
				record = where(attributes).first
			end
		end

		unless record
			record = new

			required_attributes.each do |key|
				value = attributes[key]
				record.send("#{key}=", value)
				record.errors.add(key, value.present? ? error : :blank)
			end
		end
		record
	end

	def self.find_record login
		where(["username = :value OR email = :value", {value: login}]).first
	end

end
