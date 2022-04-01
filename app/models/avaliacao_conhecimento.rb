class AvaliacaoConhecimento < ApplicationRecord
  belongs_to :ano_letivo
  belongs_to :serie, optional: true
  belongs_to :disciplina, optional: true
  belongs_to :ciclo_avaliacao, optional: true
  belongs_to :proposta_redacao_html, class_name: "PropostaRedacao", foreign_key: :proposta_redacao_id, optional: true 
  
  
  has_many :avaliacao_conhecimento_questoes, dependent: :destroy
  has_many :avaliacao_conhecimento_escolas, dependent: :destroy
  has_many :avaliacao_conhecimento_estruturas, dependent: :destroy
  has_many :turma_avaliacoes, dependent: :destroy
  has_many :serie_avaliacao_infantis, dependent: :destroy
  has_many :avaliacao_conhecimento_series, dependent: :destroy
  has_many :gestao_avaliacoes, dependent: :destroy
  has_many :ciclo_avaliacao_escola_agendamentos, dependent: :destroy
  has_many :avaliacao_conhecimento_validacoes, dependent: :destroy
  
  has_one_attached :proposta_redacao
  has_one_attached :parametros_tri
  has_many_attached :anexos

  audited on: [:update, :destroy]
  validates :descricao, :ano_letivo_id, :serie_id, :etapa, :data_aplicacao, :data_lancamento_notas, :situacao, :modelo, presence: true, if: :avaliacao_aluno?  
  validates :qtde_itens_resposta, :qtde_itens_plano_acao, presence: true, if: :avaliacao_objetiva?
  validates :descricao, :ano_letivo_id, :data_aplicacao, :situacao, :modelo, presence: true, if: :avaliacao_gestao?  

  accepts_nested_attributes_for :serie_avaliacao_infantis, :allow_destroy => true
  accepts_nested_attributes_for :avaliacao_conhecimento_series, :allow_destroy => true
  accepts_nested_attributes_for :turma_avaliacoes, :allow_destroy => true
  accepts_nested_attributes_for :avaliacao_conhecimento_escolas, :allow_destroy => true
  accepts_nested_attributes_for :avaliacao_conhecimento_questoes, :allow_destroy => true
  accepts_nested_attributes_for :avaliacao_conhecimento_estruturas, :allow_destroy => true

  enum modelo: {
    enem: 1,
    ime: 2,
    ita: 3,
    uece: 4,
    unicamp: 5,
    unifor: 6,
    usp: 7,
    sondagem: 8,
    avaliacao_simples: 9,
    gestao: 10,
    avaliacao_inteligente: 11
  }

  enum situacao: {
    pendente: 1,
    liberada_escola: 2,
    aplicada: 3,
    liberada_gestao_escola: 4,
    liberada_pais: 5,
    falhou: 6
  }

  enum etapa: {
    etapa1: 1,
    etapa2: 2,
    etapa3: 3,
    etapa4: 4,
    recuperacao: 5
  }

  enum abrangencia: {
    abrangencia_sistema_vida: 1,
    abrangencia_restrita: 2
  }

  enum qtde_itens_resposta: {
    a_b_c_d_e: 1,
    a_b_c_d: 2
  }

  enum qtde_itens_plano_acao: {
    pa_a_b_c_d_e: 1,
    pa_a_b_c_d: 2
  }

  enum versao: {
    versao_1: 1,
    versao_2: 2
  }

  enum dia_aplicacao_linguagem: {
    dia_aplicacao_linguagem_1_dia: 1,
    dia_aplicacao_linguagem_2_dia: 2,
    dia_aplicacao_linguagem_3_dia: 3,
    dia_aplicacao_linguagem_4_dia: 4,
    dia_aplicacao_linguagem_nenhum: 5
  }

  enum dia_aplicacao_humanas: {
    dia_aplicacao_humanas_1_dia: 1,
    dia_aplicacao_humanas_2_dia: 2,
    dia_aplicacao_humanas_3_dia: 3,
    dia_aplicacao_humanas_4_dia: 4,
    dia_aplicacao_humanas_nenhum: 5
  }

  enum dia_aplicacao_natureza: {
    dia_aplicacao_natureza_1_dia: 1,
    dia_aplicacao_natureza_2_dia: 2,
    dia_aplicacao_natureza_3_dia: 3,
    dia_aplicacao_natureza_4_dia: 4,
    dia_aplicacao_natureza_nenhum: 5
  }

  enum dia_aplicacao_matematica: {
    dia_aplicacao_matematica_1_dia: 1,
    dia_aplicacao_matematica_2_dia: 2,
    dia_aplicacao_matematica_3_dia: 3,
    dia_aplicacao_matematica_4_dia: 4,
    dia_aplicacao_matematica_nenhum: 5
  }

  enum dia_aplicacao_redacao: {
    dia_aplicacao_redacao_1_dia: 1,
    dia_aplicacao_redacao_2_dia: 2,
    dia_aplicacao_redacao_3_dia: 3,
    dia_aplicacao_redacao_4_dia: 4,
    dia_aplicacao_redacao_nenhum: 5
  }


  def turma_avaliacoes_com_redacao
    turma_avaliacoes = self.turma_avaliacoes.where.not(status: 10)
    
    presencial = TurmaAvaliacaoAluno.joins(:file_redacao_attachment).where('texto_redacao is null').where(turma_avaliacao_id: turma_avaliacoes.pluck(:id)).pluck(:turma_avaliacao_id).uniq
    online = TurmaAvaliacaoAluno.where('texto_redacao is not null').where(turma_avaliacao_id: turma_avaliacoes.pluck(:id)).pluck(:turma_avaliacao_id).uniq

    return (presencial + online).uniq
  end

  def avaliacao_objetiva?
    ["sondagem", "gestao"].include?(self.modelo) ? false : true
  end

  def questoes_1o_dia
    if self.modelo.eql?("enem")
      avaliacao_conhecimento_questoes = self.avaliacao_conhecimento_questoes
                                            .joins('inner join disciplinas on (avaliacao_conhecimento_questoes.disciplina_id = disciplinas.id)')
                                            .joins('inner join materias on (disciplinas.materia_id = materias.id)')
                                            .joins('inner join area_conhecimentos on (materias.area_conhecimento_id = area_conhecimentos.id)')
                                            .where("area_conhecimentos.codigo in ('A04', 'A01')")
                                            .where(lista_adaptada: false).pluck(:id)

      # avaliacao_conhecimento_questoes = self.questoes_versao1_dia(1)
    else
      avaliacao_conhecimento_questoes = self.avaliacao_conhecimento_questoes.where(lista_adaptada: false).pluck(:id)
    end
  end

  def questoes_2o_dia
    if self.modelo.eql?("enem")
      avaliacao_conhecimento_questoes = self.avaliacao_conhecimento_questoes
                                            .joins('inner join disciplinas on (avaliacao_conhecimento_questoes.disciplina_id = disciplinas.id)')
                                            .joins('inner join materias on (disciplinas.materia_id = materias.id)')
                                            .joins('inner join area_conhecimentos on (materias.area_conhecimento_id = area_conhecimentos.id)')
                                            .where("area_conhecimentos.codigo in ('A02', 'A05')")
                                            .where(lista_adaptada: false).pluck(:id)

      # avaliacao_conhecimento_questoes = self.questoes_versao1_dia(2)
    else
      avaliacao_conhecimento_questoes = nil
    end
  end

  def avaliacao_aluno?
    self.modelo.eql?("gestao") ? false : true
  end

  def avaliacao_gestao?
    self.modelo.eql?("gestao")
  end

  def area_conhecimento_dia(dia)
		nome = ''
    codigo = []
    id = []
		
    if self.dia_aplicacao_redacao.eql?("dia_aplicacao_redacao_#{dia}_dia")
      area_conhecimento = AreaConhecimento.find_by_codigo('A03')
		  nome.concat((nome.present? ? ', ' : '')).concat(area_conhecimento.nome_curto)
      codigo << area_conhecimento.codigo
      id << area_conhecimento.id
    end

    if self.dia_aplicacao_linguagem.eql?("dia_aplicacao_linguagem_#{dia}_dia")
      area_conhecimento = AreaConhecimento.find_by_codigo('A04')
		  nome.concat((nome.present? ? ', ' : '')).concat(area_conhecimento.nome_curto)
      codigo << area_conhecimento.codigo
      id << area_conhecimento.id
    end

    if self.dia_aplicacao_humanas.eql?("dia_aplicacao_humanas_#{dia}_dia")
      area_conhecimento = AreaConhecimento.find_by_codigo('A01')
		  nome.concat((nome.present? ? ', ' : '')).concat(area_conhecimento.nome_curto)
      codigo << area_conhecimento.codigo
      id << area_conhecimento.id
    end

    if self.dia_aplicacao_natureza.eql?("dia_aplicacao_natureza_#{dia}_dia")
      area_conhecimento = AreaConhecimento.find_by_codigo('A02')
		  nome.concat((nome.present? ? ', ' : '')).concat(area_conhecimento.nome_curto)
      codigo << area_conhecimento.codigo
      id << area_conhecimento.id
    end

    if self.dia_aplicacao_matematica.eql?("dia_aplicacao_matematica_#{dia}_dia")
      area_conhecimento = AreaConhecimento.find_by_codigo('A05')
		  nome.concat((nome.present? ? ', ' : '')).concat(area_conhecimento.nome_curto)
      codigo << area_conhecimento.codigo
      id << area_conhecimento.id
    end

    nome.concat('Sem Avaliação') unless nome.present? 

		return { nome: nome, codigo: codigo, id: id }
	end

  def questoes_versao1_dia(dia)
    avaliacao_conhecimento_questoes = self.avaliacao_conhecimento_questoes
              .joins('inner join disciplinas on (avaliacao_conhecimento_questoes.disciplina_id = disciplinas.id)')
              .joins('inner join materias on (disciplinas.materia_id = materias.id)')
              .joins('inner join area_conhecimentos on (materias.area_conhecimento_id = area_conhecimentos.id)')
              .where("area_conhecimentos.codigo in (?)", self.area_conhecimento_dia(dia)[:id])
              .where(lista_adaptada: false).pluck(:id)
  end

  def questoes_versao2_dia(dia)
    return self.avaliacao_conhecimento_questoes
               .where(area_conhecimento_id: self.area_conhecimento_dia(dia)[:id])
               .where(lista_adaptada: false)
               .pluck(:id)
  end

  def quantidade_dias_aplicacao
    dia = self.read_attribute_before_type_cast(:dia_aplicacao_linguagem)
    dia = self.read_attribute_before_type_cast(:dia_aplicacao_humanas) if dia < self.read_attribute_before_type_cast(:dia_aplicacao_humanas)
    dia = self.read_attribute_before_type_cast(:dia_aplicacao_natureza) if dia < self.read_attribute_before_type_cast(:dia_aplicacao_natureza)
    dia = self.read_attribute_before_type_cast(:dia_aplicacao_matematica) if dia < self.read_attribute_before_type_cast(:dia_aplicacao_matematica)
    dia = self.read_attribute_before_type_cast(:dia_aplicacao_redacao) if dia < self.read_attribute_before_type_cast(:dia_aplicacao_redacao)
    dia
  end

  def materias(_area_conhecimento_id=nil)
    if self.modelo.eql?('avaliacao_inteligente')
      materias = Materia.where(id: self.avaliacao_conhecimento_questoes.pluck(:materia_id).uniq)
    else
      materias = Materia.where(id: self.avaliacao_conhecimento_questoes.joins(:disciplina).pluck(:'disciplinas.materia_id').uniq)
    end

    if _area_conhecimento_id
      _materias = materias.where(area_conhecimento_id: _area_conhecimento_id).pluck(:id)
    else
      _materias = materias.pluck(:id)
    end
    
    return _materias
  end
  
end