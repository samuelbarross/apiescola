class CicloAvaliacaoEscolaAgendamento < ApplicationRecord
  belongs_to :ciclo_avaliacao
  belongs_to :ciclo_avaliacao_escola
  belongs_to :pessoa
  belongs_to :turma
  belongs_to :user, optional: true
  belongs_to :serie, optional: true
  belongs_to :avaliacao_conhecimento, optional: true
  belongs_to :user_liberacao, class_name: "User", foreign_key: :user_liberacao_id, optional: true 
  belongs_to :user_confirmacao, class_name: "User", foreign_key: :user_confirmacao_id, optional: true     # Planejamento
  belongs_to :user_validacao, class_name: "User", foreign_key: :user_validacao_id, optional: true         # Avaliação


  audited on: [:update, :destroy]

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

		return { nome: nome, codigo:codigo, id: id }
	end
    
end
