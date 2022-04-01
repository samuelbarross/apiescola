class Pessoa < ApplicationRecord
	belongs_to :cidade, optional: true
	belongs_to :pessoa_mae, class_name: "Pessoa", foreign_key: :pessoa_mae_id, optional: true
	belongs_to :pessoa_pai, class_name: "Pessoa", foreign_key: :pessoa_pai_id, optional: true 
	
	has_many :pessoa_grupo_entidades, dependent: :destroy
	has_many :escola_grupo_entidades, class_name: "PessoaGrupoEntidade", foreign_key: :pessoa_escola_id, dependent: :destroy
	has_many :contrato_venda_escolas, class_name: "ContratoVenda", foreign_key: :pessoa_escola_id, dependent: :destroy
	has_many :contrato_venda_vendedores, class_name: "ContratoVenda", foreign_key: :pessoa_vendedor_id, dependent: :destroy
	has_many :serie_disciplina_professores, class_name: "SerieDisciplinaProfessor", foreign_key: :pessoa_professor_id, dependent: :destroy
	# has_many :turma_alunos, -> { order(:nome) }, class_name: "TurmaAluno", foreign_key: :pessoa_aluno_id, dependent: :destroy
	has_many :turma_alunos, class_name: "TurmaAluno", foreign_key: :pessoa_aluno_id, dependent: :destroy
	has_many :pessoa_pessoa_escolas, class_name: "PessoaEscola", foreign_key: :pessoa_escola_id, dependent: :destroy
	has_many :pessoa_escolas, class_name: "PessoaEscola", foreign_key: :pessoa_id, dependent: :destroy
	has_many :pessoa_responsavel_fianceiros, class_name: "PessoaEscola", foreign_key: :pessoa_responsavel_financeiro_id, dependent: :destroy
	# has_many :turma_professores, class_name: "PessoaTurma", foreign_key: :pessoa_professor_id, dependent: :destroy
	has_many :pessoa_turma_professores, class_name: "TurmaProfessor", foreign_key: :pessoa_professor_id, dependent: :destroy
	has_many :users, dependent: :destroy
	has_many :pessoa_users, class_name: "User", foreign_key: :pessoa_id, dependent: :destroy
	has_many :pessoa_escola_turmas, class_name: "Turma", foreign_key: :pessoa_escola_id, dependent: :destroy
	has_many :avaliacao_conhecimento_escolas, class_name: "AvaliacaoConhecimentoEscola", foreign_key: :pessoa_escola_id, dependent: :destroy
	has_many :serie_avaliacao_infantil_resultados, class_name: "SerieAvaliacaoInfantilResultado", foreign_key: "pessoa_aluno_id"
	has_many :curso_nota_cortes, dependent: :destroy
	has_many :sedes, dependent: :destroy
	has_many :pessoa_responsaveis
	has_many :pessoa_pessoa_responsaveis, class_name: "Pessoa", foreign_key: "pessoa_responsavel_id"
	has_many :migracao_planilhas, dependent: :destroy
	has_many :migracao_planilha_itens, dependent: :destroy
	has_many :convite_pessoas, dependent: :destroy
	has_many :pessoa_escola_contive_pessoas, class_name: "ConvitePessoa", foreign_key: :pessoa_escola_id, dependent: :destroy
	has_many :turma_avaliacao_acompanhamentos, class_name: "TurmaAvaliacaoAcompanhamento", foreign_key: :pessoa_escola_id, dependent: :destroy
	has_many :serie_coordenacoes
	has_many :escola_serie_coordenacoes, class_name: "SerieCoordenacao", foreign_key: :pessoa_escola_id, dependent: :destroy
	has_many :escola_condicao_pagamentos, dependent: :destroy
	has_many :escola_produtos, dependent: :destroy
	has_many :pedido_vendas, dependent: :destroy
	has_many :pessoa_compradores, class_name: "PedidoVenda", foreign_key: :pessoa_comprador_id, dependent: :destroy
	has_many :produtos, dependent: :destroy
	has_many :gestao_avaliacao_pessoas, dependent: :destroy
	has_many :gestao_avaliacao_questao_respostas, dependent: :destroy
	has_many :cupom_descontos, dependent: :destroy
	has_many :livro_escolas, dependent: :destroy
	has_many :escola_material_didaticos, dependent: :destroy
	has_many :caracteristica_socio_emocionais, dependent: :destroy
	has_many :banco_questoes
	has_many :tutoria_nivel_materias
	
	
	has_one_attached :avatar
	has_many_attached :banners

  audited on: [:update, :destroy]	

  accepts_nested_attributes_for :pessoa_grupo_entidades, :allow_destroy => true
	accepts_nested_attributes_for :pessoa_escolas, :allow_destroy => true
	accepts_nested_attributes_for :pessoa_responsaveis, :allow_destroy => true
	accepts_nested_attributes_for :escola_serie_coordenacoes, :allow_destroy => true
	accepts_nested_attributes_for :escola_condicao_pagamentos, :allow_destroy => true
	accepts_nested_attributes_for :escola_produtos, :allow_destroy => true

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "tipo_pessoa", "rg", "orgao_emissor_rg", "cnpj", "data_emissao_rg", "data_nascimento", "cep", "endereco", "complemento", "bairro",
				"cidade_id", "telefone_residencial", "telefone_comercial", "telefone_celular", "telefone_celular_2", "sexo", "estado_civil", "inscricao_estadual", "inscricao_municipal", "nacionalidade", "media_anual", 
				"media_recuperacao", "disciplina_padrao_id", "modulos_svida_drupal"]

  def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  validates :nome, presence: true

	enum tipo_pessoa: {
		fisica: 1,
		juridica: 2
	}

	enum estado_civil: {
		solteiro: 1,
		casado: 2,
		separado_judicialmente: 3,
		divorciado: 4,
		viuvo: 5,
		uniao_estavel: 6,
		ignorado: 7,
		outros: 8
	}
	  
	enum sexo: {
		masculino: 1,
		feminino: 2
		# sexo_ignorado: 3
	}

	enum tipo_material: {
		tipo_material_7v: 1,
		tipo_material_14v: 2,
		tipo_material_instensivo: 3
	}

	enum perfil_comportamental: { estrategico: 1, logico: 2, lider: 3, inovador: 4, mediador: 5, executor: 6, aventureiro: 7 , empreendedor: 8 }

	def criar_usuario
		usuario = User.find_by_pessoa_id(self.id)
		if usuario.nil?	
			perfil = nil
			self.pessoa_grupo_entidades.each do |pessoa_grupo_entidade|
				case pessoa_grupo_entidade.grupo_entidade.sigla
				when 'SVD'
					perfil = 1
				when 'ALU'
					perfil = 2
				when 'PRO'
					perfil = 3
				when 'GES', 'SUP'
					perfil = 4
				when 'PAR'
					perfil = 5
				when 'VEN'
					perfil = 6
				when 'DIR'
					perfil = 7
				when 'COR'
					perfil = 8
				when 'EOL'
					perfil = 11
				when 'ADS'
					perfil = 13
				when 'PSI'
					perfil = 14					
				end	
			end

			pessoa_escola = PessoaEscola.where(pessoa_id: self.id).first
			unless pessoa_escola.nil?
				if self.email.nil? or self.email.empty?
					usuario = nil
				else
					usuario = User.find_by_email(self.email)
				end

				if usuario.nil?
					username = generate_username(RetornarDados.sugestao_nome_usuario(self.nome).parameterize(separator: '_'))
					username = find_unique_username(username)

					user = User.new
					user.email = self.email
					user.name = self.nome
					user.username = username
					user.password = '12345678'
					user.password_confirmation = '12345678'
					user.pessoa_id = self.id
					user.sexo = self.sexo
					user.ano_letivo_id = Configuracao.first.ano_letivo_id
					user.pessoa_escola_id = pessoa_escola.pessoa_escola_id
					user.perfil = perfil
					user.created_at = Time.now.zone
					user.updated_at = Time.now.zone
					user.save(validate: false)

					# PessoaMailer.with(pessoa: self).confirmacao_registro.deliver_later if perfil.eql?('PRO')
				end
			end
		else
			if usuario.username.nil?
				username = generate_username(RetornarDados.sugestao_nome_usuario(self.nome).parameterize(separator: '_'))
				username = find_unique_username(username)
				usuario.update!(username: username)
			end
		end
	end	

	def primeira_habilitacao
		primeira_habilitacao = ''
		pessoa_grupo_entidade = self.pessoa_grupo_entidades.first
		if !pessoa_grupo_entidade.nil?
			primeira_habilitacao = pessoa_grupo_entidade.grupo_entidade.sigla
		end
		primeira_habilitacao
	end

	def eh_gestao_vida?
		retorno = false
		self.pessoa_grupo_entidades.each do |pessoa_grupo_entidade|
			if pessoa_grupo_entidade.grupo_entidade.sigla == 'SVD'
				retorno = true
			end
		end
		retorno
	end

	def eh_escola?
		retorno = false
		self.pessoa_grupo_entidades.each do |pessoa_grupo_entidade|
			if pessoa_grupo_entidade.grupo_entidade.sigla == 'ESC'
				retorno = true
			end
		end
		retorno
	end

	def eh_professor?
		retorno = false
		self.pessoa_grupo_entidades.each do |pessoa_grupo_entidade|
			if pessoa_grupo_entidade.grupo_entidade.sigla == 'PRO'
				retorno = true
			end
		end
		retorno
	end

	def eh_aluno?
		retorno = false
		self.pessoa_grupo_entidades.each do |pessoa_grupo_entidade|
			if pessoa_grupo_entidade.grupo_entidade.sigla == 'ALU'
				retorno = true
			end
		end
		retorno
	end

	def eh_usuario?
		!User.find_by_pessoa_id(self.id).nil?
	end

	def generate_username(fullname)
    ActiveSupport::Inflector.transliterate(fullname) # change ñ => n
      .downcase              # only lower case
      .strip                 # remove spaces around the string
      .gsub(/[^a-z]/, '_')   # any character that is not a letter or a number will be _
      .gsub(/\A_+/, '')      # remove underscores at the beginning
      .gsub(/_+\Z/, '')      # remove underscores at the end
      .gsub(/_+/, '_')       # maximum an underscore in a row
	end	
	
	def find_unique_username(username)
    taken_usernames = User
      .where("username LIKE ?", "#{username}%")
      .pluck(:username)

    # username if it's free
    return username if ! taken_usernames.include?(username)

    count = 2
    while true
      # username_2, username_3...
      new_username = "#{username}_#{count}"
      return new_username if ! taken_usernames.include?(new_username)
      count += 1
    end
	end	

	def gerar_key_ecommerce
		if self.chave_url_ecommerce.nil?
			#Alteração solicitada pelo Felipe
			# num_id = self.id.to_s.rjust(4, '0')
			# self.update(chave_url_ecommerce: 'Ecm-Svd-A' + num_id[0] + '-b' + num_id[1] + '-C' + num_id[2] + '-d' + num_id[3] + '-' + self.created_at.year.to_s)
			self.update(chave_url_ecommerce: 'E-' + self.id.to_s.rjust(4, '0') + '-' + self.created_at.year.to_s)
		end
	end

	def cpf_cnpj_formatado
		case self.tipo_pessoa
		when 'fisica'
			cpf_cnpj_formatado = self.cpf.to_s.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, "\\1.\\2.\\3-\\4")
		when 'juridica'
			cpf_cnpj_formatado = self.cnpj.to_s.gsub(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, "\\1.\\2.\\3/\\4-\\5")
		end

		cpf_cnpj_formatado
	end

	def cep_formatado
		self.cep.to_s.gsub(/(\d{2})(\d{3})(\d{3})/, "\\1.\\2-\\3")
	end

	def series_ano_letivo(ano_letivo_id)
		Serie.where(id: self.pessoa_escola_turmas.where(ano_letivo_id: ano_letivo_id).pluck(:serie_id).uniq)
	end

	def indice_proficiencia(materia, ano_letivo_id)
		_indice_proficiencia = 0

		turma_aluno = self.turma_alunos.joins(:turma).where(turmas: {ano_letivo_id: ano_letivo_id}).first
		if turma_aluno
			case materia.area_conhecimento.codigo
			when 'A04'
				_indice_proficiencia = turma_aluno.turma_avaliacao_alunos.first.indice_proficiencia_tri_linguagens|| 0
			when 'A01'
				_indice_proficiencia = turma_aluno.turma_avaliacao_alunos.first.indice_proficiencia_tri_humanas|| 0
			when 'A02'
				_indice_proficiencia = turma_aluno.turma_avaliacao_alunos.first.indice_proficiencia_tri_natureza|| 0
			when 'A05'
				_indice_proficiencia = turma_aluno.turma_avaliacao_alunos.first.indice_proficiencia_tri_matematica|| 0
			end
		end

		_indice_proficiencia.to_f
	end

	def escola_serie_turma(_ano_letivo_id)
		if self.eh_aluno?
			pessoa_escola = self.pessoa_escolas.where(ano_letivo_id: _ano_letivo_id).first
			turma_aluno = self.turma_alunos.joins(:turma).where(turmas: {ano_letivo_id: _ano_letivo_id}).first
			
			return { pesssoa_escola_id: pessoa_escola.id, turma_id: turma_aluno.turma_id, serie_codigo: turma_aluno.turma.serie.codigo, nivel_codigo: turma_aluno.turma.serie.nivel.codigo }
		else
			return { pesssoa_escola_id: nil, turma_id: nil, serie_codigo: nil, nivel_codigo: nil }
		end
	end

	def turma_do_aluno(_ano_letivo_id)
		self.turma_alunos.joins(:turma).where(turmas: { ano_letivo_id: _ano_letivo_id}).where(turma_alunos: {status: :ativo}).first.turma
	end

	def lista_materia_professor_tutoria(abrangencia=nil, nivel_id=nil) #1-Dúvida | 2-Aula
		if self.eh_professor?
			rs = self.tutoria_nivel_materias.where(ativo: true)

			rs = rs.where(permissao_tira_duvida: true) if abrangencia.eql? 1
			rs = rs.where(permissao_ministrar_aula: true) if abrangencia.eql? 2
			rs = rs.where(nivel_id: nivel_id) unless nivel_id.nil?

			rs.pluck(:materia_id).uniq
		else
			[]
		end
	end

end
