class TurmaAvaliacao < ApplicationRecord
	belongs_to :turma
	belongs_to :disciplina, optional: true
	belongs_to :contrato_venda_ano_letivo_etapa, optional: true
	belongs_to :pessoa, class_name: "Pessoa", foreign_key: :pessoa_professor_id, optional: true
	belongs_to :avaliacao_conhecimento
	
	has_many :turma_avaliacao_questoes, dependent: :destroy
	has_many :turma_avaliacao_alunos, dependent: :destroy
	has_many :turma_avaliacao_resultados, dependent: :destroy
	has_many :serie_avaliacao_infantil_resultados, dependent: :destroy
	has_many :turma_avaliacao_marcacoes, dependent: :destroy
	has_many :turma_avaliacao_lista_adaptadas, dependent: :destroy
	has_many :turma_avaliacao_acompanhamentos, dependent: :destroy
	has_many :registro_navegacoes, dependent: :destroy
	has_many :turma_avaliacao_questao_respostas, dependent: :destroy
	has_many :resultado_plano_acoes, dependent: :destroy
	has_many :ia_plano_acoes, dependent: :destroy
	has_many :turma_avaliacao_roteiro_estudos, dependent: :destroy


  after_save :atualizar_datas_2a_chamada

  audited on: [:update, :destroy]
	
	has_one_attached :arquivo_cartao_resposta_1
	has_one_attached :arquivo_cartao_resposta_2
	has_one_attached :planilha_tri_linguagens
	has_one_attached :planilha_tri_humanas
	has_one_attached :planilha_tri_natureza
	has_one_attached :planilha_tri_matematica
	has_one_attached :planilha_tri_linguagens_pa
	has_one_attached :planilha_tri_humanas_pa
	has_one_attached :planilha_tri_natureza_pa
	has_one_attached :planilha_tri_matematica_pa

	enum modelo: {
  	padrao: 1,
  	enem: 2,
		sondagem: 3
	}
	
	enum status: {
		aguardando_anexo: 1,
		aguardando_processamento: 2,
		processando_cartao_resposta: 3,
		processando_resultado: 4,
		gerando_plano_acao_aluno: 5,
		gerando_plano_acao_professor: 6,
		concluido: 7,
		falhou: 8,
		liberado: 9,
		nao_aplicar: 10
	}

	def nota_media_redacao
		self.turma_avaliacao_alunos.where.not(nota_redacao: nil).average(:nota_redacao).to_f
	end

	def maior_nota_redacao
		self.turma_avaliacao_alunos.where.not(nota_redacao: nil).maximum(:nota_redacao).to_f
	end

	def menor_nota_redacao
		self.turma_avaliacao_alunos.where.not(nota_redacao: nil).minimum(:nota_redacao).to_f
	end

  def link_calendario
    case Rails.env.to_s
    when "development"
      "http://localhost:3000/turma_avaliacoes/#{self.id}"
    when
      "https://www.vidaeducacao.com.br/admin/turma_avaliacoes/#{self.id}"
    end
	end	
	
	def lista_presentes_1o_dia
		if self.realizado_online?
			self.turma_avaliacao_alunos.where.not(data_abertura_online_1_dia: nil).map(&:turma_aluno_id)
		else
			self.turma_avaliacao_marcacoes.where('length(marcacao) > 0').map(&:turma_aluno_id)
		end
	end

	def lista_presentes_2o_dia
		if self.realizado_online?
			self.turma_avaliacao_alunos.where.not(data_abertura_online_2_dia: nil).map(&:turma_aluno_id)
		else
			self.turma_avaliacao_marcacoes.where('length(marcacao_2) > 0').map(&:turma_aluno_id)
		end
	end

	def lista_presentes_total
		if self.realizado_online?
			self.turma_avaliacao_alunos.where('data_abertura_online_1_dia is not null or data_abertura_online_2_dia is not null').map(&:turma_aluno_id)
		else
			self.turma_avaliacao_marcacoes.where('length(marcacao) > 0 or length(marcacao_2) > 0').map(&:turma_aluno_id)
		end
	end

	def lista_questoes_versao1_1o_dia
		case self.avaliacao_conhecimento.modelo
		when "enem", "avaliacao_inteligente"
			avaliacao_conhecimento_questoes = self.avaliacao_conhecimento.avaliacao_conhecimento_questoes
																						.joins('inner join disciplinas on (avaliacao_conhecimento_questoes.disciplina_id = disciplinas.id)')
																						.joins('inner join materias on (disciplinas.materia_id = materias.id)')
																						.joins('inner join area_conhecimentos on (materias.area_conhecimento_id = area_conhecimentos.id)') 
																						.where('area_conhecimentos.codigo in (?)', ["A01", "A04"])
																						.where('avaliacao_conhecimento_questoes.lista_adaptada = false')

		when "avaliacao_simples"
			avaliacao_conhecimento_questoes = self.avaliacao_conhecimento.avaliacao_conhecimento_questoes

		when "uece"
			avaliacao_conhecimento_questoes = self.avaliacao_conhecimento.avaliacao_conhecimento_questoes
		end
	end

	def lista_questoes_versao1_2o_dia
		case self.avaliacao_conhecimento.modelo
		when "enem", "avaliacao_inteligente"
			avaliacao_conhecimento_questoes = self.avaliacao_conhecimento.avaliacao_conhecimento_questoes
																						.joins('inner join disciplinas on (avaliacao_conhecimento_questoes.disciplina_id = disciplinas.id)')
																						.joins('inner join materias on (disciplinas.materia_id = materias.id)')
																						.joins('inner join area_conhecimentos on (materias.area_conhecimento_id = area_conhecimentos.id)') 
																						.where('area_conhecimentos.codigo in (?)', ["A02", "A05"])
																						.where('avaliacao_conhecimento_questoes.lista_adaptada = false')

		when "avaliacao_simples"
			nil

		when "uece"
			nil
		end
	end

  def lista_presentes(dia, segunda_chamada)
    lista = []

    # if self.avaliacao_conhecimento.modelo.eql?('avaliacao_inteligente')
    if self.avaliacao_conhecimento.versao.eql?('versao_2')
      # stSQL = "select taa.turma_aluno_id from turma_avaliacao_alunos taa where taa.turma_avaliacao_id = #{self.id} "

      # unless segunda_chamada
      #   stSQL << " and taa.data_abertura_online_#{dia}_dia is not null;"
      # else
      #   stSQL << " and taa.aplicar_2a_chamada_#{dia}_dia = true and taa.data_hora_inicial_#{dia}_dia_2a_chamada is not null; "
      # end

      # regs = ActiveRecord::Base.connection.execute(stSQL).to_a
      # regs.each do |reg|
      #   lista << reg.values
      # end

      unless segunda_chamada
        lista = self.turma_avaliacao_alunos.where("data_abertura_online_#{dia}_dia is not null").pluck(:turma_aluno_id)
      else
        lista = self.turma_avaliacao_alunos.where("data_abertura_online_#{dia}_dia_2a_chamada is not null").where("aplicar_2a_chamada_#{dia}_dia = true").pluck(:turma_aluno_id)
      end

    end

    return lista
  end

	def desempenho_area_conhecimento
		menor_nota_geral = 0
    maior_nota_geral = 0
    media_nota_geral = 0

    menor_nota_turma_humanas = 0
    maior_nota_turma_humanas = 0
    media_nota_turma_humanas = 0

    menor_nota_turma_natureza = 0
    maior_nota_turma_natureza = 0
    media_nota_turma_natureza = 0

    menor_nota_turma_linguagens = 0
    maior_nota_turma_linguagens = 0
    media_nota_turma_linguagens = 0

    menor_nota_turma_matematica = 0
    maior_nota_turma_matematica = 0
    media_nota_turma_matematica = 0

    menor_nota_turma_redacao = 0
    maior_nota_turma_redacao = 0
    media_nota_turma_redacao = 0
    qtd_presentes_1_dia = 0
    qtd_presentes_2_dia = 0

    qtde_alunos_habilitados = self.turma_avaliacao_alunos.count
    if self.realizado_online?
      qtd_alunos_presentes_avaliacao = self.turma_avaliacao_alunos.where('data_abertura_online_1_dia is not null or data_abertura_online_2_dia is not null').count
    else
      qtd_alunos_presentes_avaliacao = self.turma_avaliacao_marcacoes.where('length(marcacao) > 0 or length(marcacao_2) > 0').count
    end
    lista_turma_alunos_1_dia = self.lista_presentes_1o_dia
    lista_turma_alunos_2_dia = self.lista_presentes_2o_dia

    qtd_presentes_1_dia = lista_turma_alunos_1_dia.count
    qtd_presentes_2_dia = lista_turma_alunos_2_dia.count

    if qtde_alunos_habilitados > 0 
      percentual_alunos_presentes = (qtd_alunos_presentes_avaliacao.to_f / qtde_alunos_habilitados.to_f * 100.0).round(2)
    else
      percentual_alunos_presentes = 0
    end

    AreaConhecimento.where.not(codigo: "A03").each do |area_conhecimento|
      case area_conhecimento.codigo
      when 'A01', 'A04'
        turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 6).where(area_conhecimento_id: area_conhecimento.id).where(turma_aluno_id: lista_turma_alunos_1_dia).select('coalesce(min(nota), 0) menor_nota, coalesce(max(nota), 0) maior_nota').order(1).first
      when 'A02', 'A05'
        if ["enem", "avaliacao_inteligente"].include?(self.avaliacao_conhecimento.modelo)
          turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 6).where(area_conhecimento_id: area_conhecimento.id).where(turma_aluno_id: lista_turma_alunos_2_dia).select('coalesce(min(nota), 0) menor_nota, coalesce(max(nota), 0) maior_nota').order(1).first
        else
          turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 6).where(area_conhecimento_id: area_conhecimento.id).where(turma_aluno_id: lista_turma_alunos_1_dia).select('coalesce(min(nota), 0) menor_nota, coalesce(max(nota), 0) maior_nota').order(1).first
        end
      end

      if turma_avaliacao_resultado
        case area_conhecimento.codigo
        when 'A01'
          menor_nota_turma_humanas = turma_avaliacao_resultado.menor_nota.to_f
          maior_nota_turma_humanas = turma_avaliacao_resultado.maior_nota.to_f
          media_nota_turma_humanas = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
        when 'A02'
          menor_nota_turma_natureza = turma_avaliacao_resultado.menor_nota.to_f
          maior_nota_turma_natureza = turma_avaliacao_resultado.maior_nota.to_f
          media_nota_turma_natureza = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
        when 'A04'
          menor_nota_turma_linguagens = turma_avaliacao_resultado.menor_nota.to_f
          maior_nota_turma_linguagens = turma_avaliacao_resultado.maior_nota.to_f
          media_nota_turma_linguagens = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
        when 'A05'
          menor_nota_turma_matematica = turma_avaliacao_resultado.menor_nota.to_f
          maior_nota_turma_matematica = turma_avaliacao_resultado.maior_nota.to_f
          media_nota_turma_matematica = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
        end    
      end
    end

    menor_nota_geral = [menor_nota_turma_humanas, menor_nota_turma_natureza, menor_nota_turma_linguagens, menor_nota_turma_matematica].min.to_f
    maior_nota_geral = [maior_nota_turma_humanas, maior_nota_turma_natureza, maior_nota_turma_linguagens, maior_nota_turma_matematica].max.to_f

    media_nota_geral = ((media_nota_turma_linguagens + media_nota_turma_humanas + media_nota_turma_natureza + media_nota_turma_matematica) / 4).to_f

    menor_nota_turma_redacao = self.menor_nota_redacao.to_f
    maior_nota_turma_redacao = self.maior_nota_redacao.to_f
    media_nota_turma_redacao = ((self.menor_nota_redacao + self.maior_nota_redacao) / 2).to_f

    desempenho_area_conhecimento = {
			menor_nota_geral: menor_nota_geral, maior_nota_geral: maior_nota_geral, media_nota_geral: media_nota_geral, 
			menor_nota_turma_humanas: menor_nota_turma_humanas, maior_nota_turma_humanas: maior_nota_turma_humanas, media_nota_turma_humanas: media_nota_turma_humanas, 
			menor_nota_turma_linguagens: menor_nota_turma_linguagens, maior_nota_turma_linguagens: maior_nota_turma_linguagens, media_nota_turma_linguagens: media_nota_turma_linguagens, 
			menor_nota_turma_matematica: menor_nota_turma_matematica, maior_nota_turma_matematica: maior_nota_turma_matematica, media_nota_turma_matematica: media_nota_turma_matematica, 
			menor_nota_turma_redacao: menor_nota_turma_redacao, maior_nota_turma_redacao: maior_nota_turma_redacao, media_nota_turma_redacao: media_nota_turma_redacao, 
			menor_nota_turma_natureza: menor_nota_turma_natureza, maior_nota_turma_natureza: maior_nota_turma_natureza, media_nota_turma_natureza: media_nota_turma_natureza, 
			qtde_alunos_habilitados: qtde_alunos_habilitados, qtd_alunos_presentes_avaliacao: qtd_alunos_presentes_avaliacao, percentual_alunos_presentes: percentual_alunos_presentes, 
			qtd_presentes_1_dia: qtd_presentes_1_dia, qtd_presentes_2_dia: qtd_presentes_2_dia
		}
  end		

	def desempenho_area_conhecimento_v2
		menor_nota_geral = 0
    maior_nota_geral = 0
    media_nota_geral = 0

    menor_nota_turma_humanas = 0
    maior_nota_turma_humanas = 0
    media_nota_turma_humanas = 0

    menor_nota_turma_natureza = 0
    maior_nota_turma_natureza = 0
    media_nota_turma_natureza = 0

    menor_nota_turma_linguagens = 0
    maior_nota_turma_linguagens = 0
    media_nota_turma_linguagens = 0

    menor_nota_turma_matematica = 0
    maior_nota_turma_matematica = 0
    media_nota_turma_matematica = 0

    menor_nota_turma_redacao = 0
    maior_nota_turma_redacao = 0
    media_nota_turma_redacao = 0
    qtd_presentes_1_dia = 0
    qtd_presentes_2_dia = 0

    qtde_alunos_habilitados = self.turma_avaliacao_alunos.count
    if self.realizado_online?
      qtd_alunos_presentes_avaliacao = self.turma_avaliacao_alunos.where('data_abertura_online_1_dia is not null or data_abertura_online_2_dia is not null').count
    else
      qtd_alunos_presentes_avaliacao = self.turma_avaliacao_marcacoes.where('length(marcacao) > 0 or length(marcacao_2) > 0').count
    end
    lista_turma_alunos_1_dia = self.lista_presentes_1o_dia
    lista_turma_alunos_2_dia = self.lista_presentes_2o_dia

    qtd_presentes_1_dia = lista_turma_alunos_1_dia.count
    qtd_presentes_2_dia = lista_turma_alunos_2_dia.count

    if qtde_alunos_habilitados > 0 
      percentual_alunos_presentes = (qtd_alunos_presentes_avaliacao.to_f / qtde_alunos_habilitados.to_f * 100.0).round(2)
    else
      percentual_alunos_presentes = 0
    end

    AreaConhecimento.where.not(codigo: "A03").each do |area_conhecimento|
      case area_conhecimento.codigo
      when 'A01', 'A04'
        turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 6).where(area_conhecimento_id: area_conhecimento.id).where(turma_aluno_id: lista_turma_alunos_1_dia).select('coalesce(min(nota), 0) menor_nota, coalesce(max(nota), 0) maior_nota, coalesce(avg(nota), 0) media').order(1).first
      when 'A02', 'A05'
        if ["enem", "avaliacao_inteligente"].include?(self.avaliacao_conhecimento.modelo)
          turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 6).where(area_conhecimento_id: area_conhecimento.id).where(turma_aluno_id: lista_turma_alunos_2_dia).select('coalesce(min(nota), 0) menor_nota, coalesce(max(nota), 0) maior_nota, coalesce(avg(nota), 0) media').order(1).first
        else
          turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 6).where(area_conhecimento_id: area_conhecimento.id).where(turma_aluno_id: lista_turma_alunos_1_dia).select('coalesce(min(nota), 0) menor_nota, coalesce(max(nota), 0) maior_nota, coalesce(avg(nota), 0) media').order(1).first
        end
      end

      if turma_avaliacao_resultado
        case area_conhecimento.codigo
        when 'A01'
          menor_nota_turma_humanas = turma_avaliacao_resultado.menor_nota.to_f
          maior_nota_turma_humanas = turma_avaliacao_resultado.maior_nota.to_f
          # media_nota_turma_humanas = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
          media_nota_turma_humanas = turma_avaliacao_resultado.media.to_f.to_f
        when 'A02'
          menor_nota_turma_natureza = turma_avaliacao_resultado.menor_nota.to_f
          maior_nota_turma_natureza = turma_avaliacao_resultado.maior_nota.to_f
					# media_nota_turma_natureza = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
					media_nota_turma_natureza = turma_avaliacao_resultado.media.to_f.to_f
        when 'A04'
          menor_nota_turma_linguagens = turma_avaliacao_resultado.menor_nota.to_f
					maior_nota_turma_linguagens = turma_avaliacao_resultado.maior_nota.to_f
          # media_nota_turma_linguagens = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
					media_nota_turma_linguagens = turma_avaliacao_resultado.media.to_f.to_f
        when 'A05'
          menor_nota_turma_matematica = turma_avaliacao_resultado.menor_nota.to_f
          maior_nota_turma_matematica = turma_avaliacao_resultado.maior_nota.to_f
          # media_nota_turma_matematica = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
          media_nota_turma_matematica = turma_avaliacao_resultado.media.to_f.to_f
        end    
      end
    end

    menor_nota_geral = [menor_nota_turma_humanas, menor_nota_turma_natureza, menor_nota_turma_linguagens, menor_nota_turma_matematica].min.to_f
    maior_nota_geral = [maior_nota_turma_humanas, maior_nota_turma_natureza, maior_nota_turma_linguagens, maior_nota_turma_matematica].max.to_f

    media_nota_geral = ((media_nota_turma_linguagens + media_nota_turma_humanas + media_nota_turma_natureza + media_nota_turma_matematica) / 4).to_f

    menor_nota_turma_redacao = self.menor_nota_redacao.to_f
    maior_nota_turma_redacao = self.maior_nota_redacao.to_f
    media_nota_turma_redacao = ((self.menor_nota_redacao + self.maior_nota_redacao) / 2).to_f

    desempenho_area_conhecimento = {
			menor_nota_geral: menor_nota_geral, maior_nota_geral: maior_nota_geral, media_nota_geral: media_nota_geral, 
			menor_nota_turma_humanas: menor_nota_turma_humanas, maior_nota_turma_humanas: maior_nota_turma_humanas, media_nota_turma_humanas: media_nota_turma_humanas, 
			menor_nota_turma_linguagens: menor_nota_turma_linguagens, maior_nota_turma_linguagens: maior_nota_turma_linguagens, media_nota_turma_linguagens: media_nota_turma_linguagens, 
			menor_nota_turma_matematica: menor_nota_turma_matematica, maior_nota_turma_matematica: maior_nota_turma_matematica, media_nota_turma_matematica: media_nota_turma_matematica, 
			menor_nota_turma_redacao: menor_nota_turma_redacao, maior_nota_turma_redacao: maior_nota_turma_redacao, media_nota_turma_redacao: media_nota_turma_redacao, 
			menor_nota_turma_natureza: menor_nota_turma_natureza, maior_nota_turma_natureza: maior_nota_turma_natureza, media_nota_turma_natureza: media_nota_turma_natureza, 
			qtde_alunos_habilitados: qtde_alunos_habilitados, qtd_alunos_presentes_avaliacao: qtd_alunos_presentes_avaliacao, percentual_alunos_presentes: percentual_alunos_presentes, 
			qtd_presentes_1_dia: qtd_presentes_1_dia, qtd_presentes_2_dia: qtd_presentes_2_dia
		}
  end		

  def notas
    nota_classica_linguagens = 0.0
    nota_classica_humanas = 0.0
    nota_classica_natureza = 0.0
    nota_classica_matematica = 0.0
    nota_tri_linguagens = 0.0
    nota_tri_humanas = 0.0
    nota_tri_natureza = 0.0
    nota_tri_matematica = 0.0
    nota_tri_linguagens_pa = 0.0
    nota_tri_humanas_pa = 0.0
    nota_tri_natureza_pa = 0.0
    nota_tri_matematica_pa = 0.0
    nota_redacao = 0.0
    media_classica = 0.0
    media_tri = 0.00
    media_tri_pa = 0.00
		percentual_desempenho_pa_linguagens = nil
		percentual_desempenho_pa_humanas = nil
		percentual_desempenho_pa_natureza = nil
		percentual_desempenho_pa_matematica = nil    

    case self.avaliacao_conhecimento.modelo
    when "enem", "avaliacao_inteligente"
      AreaConhecimento.all.order(:ordem_plano_acao).each do |area_conhecimento| 
        turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 8).where(area_conhecimento_id: area_conhecimento.id).first
        resultado_plano_acao = self.resultado_plano_acoes.where(area_conhecimento_id: area_conhecimento.id).where(tipo_registro: 4).first
        
        case area_conhecimento.codigo
        when "A01"
          nota_classica_humanas = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
          nota_tri_humanas = turma_avaliacao_resultado.nota_tri if turma_avaliacao_resultado
          nota_tri_humanas_pa = turma_avaliacao_resultado.nota_tri_pa if turma_avaliacao_resultado
          percentual_desempenho_pa_humanas = resultado_plano_acao.percentual_desempenho if resultado_plano_acao
        when "A02"
          nota_classica_natureza = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
          nota_tri_natureza = turma_avaliacao_resultado.nota_tri if turma_avaliacao_resultado
          nota_tri_natureza_pa = turma_avaliacao_resultado.nota_tri_pa if turma_avaliacao_resultado
          percentual_desempenho_pa_natureza = resultado_plano_acao.percentual_desempenho if resultado_plano_acao
        when "A04"
          nota_classica_linguagens = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
          nota_tri_linguagens = turma_avaliacao_resultado.nota_tri if turma_avaliacao_resultado
          nota_tri_linguagens_pa = turma_avaliacao_resultado.nota_tri_pa if turma_avaliacao_resultado
          percentual_desempenho_pa_linguagens = resultado_plano_acao.percentual_desempenho if resultado_plano_acao
        when "A03"
          nota_redacao = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
        when "A05"
          nota_classica_matematica = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
          nota_tri_matematica = turma_avaliacao_resultado.nota_tri if turma_avaliacao_resultado
          nota_tri_matematica_pa = turma_avaliacao_resultado.nota_tri_pa if turma_avaliacao_resultado
          percentual_desempenho_pa_matematica = resultado_plano_acao.percentual_desempenho if resultado_plano_acao
        end
      end

      turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 1).first
      media_classica = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
      media_tri = turma_avaliacao_resultado.nota_tri if turma_avaliacao_resultado
      media_tri_pa = turma_avaliacao_resultado.nota_tri_pa if turma_avaliacao_resultado

    when "uece"
      AreaConhecimento.all.order(:ordem_plano_acao).each do |area_conhecimento| 
        turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 8).where(area_conhecimento_id: area_conhecimento.id).first
        resultado_plano_acao = self.resultado_plano_acoes.where(area_conhecimento_id: area_conhecimento.id).where(tipo_registro: 4).first
        
        case area_conhecimento.codigo
        when "A01"
          nota_classica_humanas = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
          percentual_desempenho_pa_humanas = resultado_plano_acao.percentual_desempenho if resultado_plano_acao
        when "A02"
          nota_classica_natureza = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
          percentual_desempenho_pa_natureza = resultado_plano_acao.percentual_desempenho if resultado_plano_acao
        when "A04"
          nota_classica_linguagens = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
          percentual_desempenho_pa_linguagens = resultado_plano_acao.percentual_desempenho if resultado_plano_acao
        when "A03"
          nota_redacao = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
        when "A05"
          nota_classica_matematica = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
          percentual_desempenho_pa_matematica = resultado_plano_acao.percentual_desempenho if resultado_plano_acao
        end
      end  
      
      turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 1).first
      media_classica = turma_avaliacao_resultado.nota if turma_avaliacao_resultado

    when "avaliacao_simples"
      turma_avaliacao_resultado = self.turma_avaliacao_resultados.where(tipo_registro: 1).first
      media_classica = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
    end

    return {
      nota_classica_linguagens: nota_classica_linguagens, nota_classica_humanas: nota_classica_humanas, nota_classica_natureza: nota_classica_natureza, nota_classica_matematica: nota_classica_matematica,
      nota_tri_linguagens: nota_tri_linguagens, nota_tri_humanas: nota_tri_humanas, nota_tri_natureza: nota_tri_natureza, nota_tri_matematica: nota_tri_matematica, 
      nota_tri_linguagens_pa: nota_tri_linguagens_pa, nota_tri_humanas_pa: nota_tri_humanas_pa, nota_tri_natureza_pa: nota_tri_natureza_pa, nota_tri_matematica_pa: nota_tri_matematica_pa, 
      nota_redacao: nota_redacao, media_classica: media_classica, media_tri: media_tri, media_tri_pa: media_tri_pa,
      percentual_desempenho_pa_linguagens: percentual_desempenho_pa_linguagens, percentual_desempenho_pa_humanas: percentual_desempenho_pa_humanas, percentual_desempenho_pa_natureza: percentual_desempenho_pa_natureza, percentual_desempenho_pa_matematica: percentual_desempenho_pa_matematica
    }
  end

  def atualizar_datas_2a_chamada
    self.update_columns(data_hora_inicial_1_dia: nil,  data_hora_final_1_dia: nil) if self.avaliacao_conhecimento.area_conhecimento_dia(1)[:nome].eql?('Sem Avaliação')
    self.update_columns(data_hora_inicial_2_dia: nil,  data_hora_final_2_dia: nil) if self.avaliacao_conhecimento.area_conhecimento_dia(2)[:nome].eql?('Sem Avaliação')
    self.update_columns(data_hora_inicial_3_dia: nil,  data_hora_final_3_dia: nil) if self.avaliacao_conhecimento.area_conhecimento_dia(3)[:nome].eql?('Sem Avaliação')
    self.update_columns(data_hora_inicial_4_dia: nil,  data_hora_final_4_dia: nil) if self.avaliacao_conhecimento.area_conhecimento_dia(4)[:nome].eql?('Sem Avaliação')
    self.update_columns(data_hora_inicial_5_dia: nil,  data_hora_final_5_dia: nil) if self.avaliacao_conhecimento.area_conhecimento_dia(5)[:nome].eql?('Sem Avaliação')
    
    self.update_columns(data_hora_inicial_1_dia_2a_chamada: nil,  data_hora_final_1_dia_2a_chamada: nil) unless self.aplicar_2a_chamada_1_dia
    self.update_columns(data_hora_inicial_2_dia_2a_chamada: nil,  data_hora_final_2_dia_2a_chamada: nil) unless self.aplicar_2a_chamada_2_dia
    self.update_columns(data_hora_inicial_3_dia_2a_chamada: nil,  data_hora_final_3_dia_2a_chamada: nil) unless self.aplicar_2a_chamada_3_dia
    self.update_columns(data_hora_inicial_4_dia_2a_chamada: nil,  data_hora_final_4_dia_2a_chamada: nil) unless self.aplicar_2a_chamada_4_dia
    self.update_columns(data_hora_inicial_5_dia_2a_chamada: nil,  data_hora_final_5_dia_2a_chamada: nil) unless self.aplicar_2a_chamada_5_dia
  end

  def permite_resposta_bk
    _permite_resposta = false
    _dia = 0
    _segunda_chamada = false
    _data_inicio = nil
    _data_final = nil

    if self.realizado_online
      case Time.zone.now
      when (self.data_hora_inicial_1_dia || 0)..(self.data_hora_final_1_dia || 0)
        _dia = 1
        _data_inicio = self.data_hora_inicial_1_dia
        _data_final = self.data_hora_final_1_dia
      when (self.data_hora_inicial_2_dia || 0)..(self.data_hora_final_2_dia || 0)
        _dia = 2
        _data_inicio = self.data_hora_inicial_2_dia
        _data_final = self.data_hora_final_2_dia
      when (self.data_hora_inicial_3_dia || 0)..(self.data_hora_final_3_dia || 0)
        _dia = 3
        _data_inicio = self.data_hora_inicial_3_dia
        _data_final = self.data_hora_final_3_dia
      when (self.data_hora_inicial_4_dia || 0)..(self.data_hora_final_4_dia || 0)
        _dia = 4
        _data_inicio = self.data_hora_inicial_4_dia
        _data_final = self.data_hora_final_4_dia
      when (self.data_hora_inicial_5_dia || 0)..(self.data_hora_final_5_dia || 0)
        _dia = 5
        _data_inicio = self.data_hora_inicial_5_dia
        _data_final = self.data_hora_final_5_dia
      when (self.aplicar_2a_chamada_1_dia and (self.data_hora_inicial_1_dia_2a_chamada || 0)..(self.data_hora_final_1_dia_2a_chamada || 0))
        _dia = 1
        _segunda_chamada = true
        _data_inicio = self.data_hora_inicial_1_dia_2a_chamada
        _data_final = self.data_hora_final_1_dia_2a_chamada
      when (self.aplicar_2a_chamada_2_dia and (self.data_hora_inicial_2_dia_2a_chamada || 0)..(self.data_hora_final_2_dia_2a_chamada || 0))
        _dia = 2
        _segunda_chamada = true
        _data_inicio = self.data_hora_inicial_2_dia_2a_chamada
        _data_final = self.data_hora_final_2_dia_2a_chamada
      when (self.aplicar_2a_chamada_3_dia and (self.data_hora_inicial_3_dia_2a_chamada || 0)..(self.data_hora_final_3_dia_2a_chamada || 0))
        _dia = 3
        _segunda_chamada = true
        _data_inicio = self.data_hora_inicial_3_dia_2a_chamada
        _data_final = self.data_hora_final_3_dia_2a_chamada
      when (self.aplicar_2a_chamada_4_dia and (self.data_hora_inicial_4_dia_2a_chamada || 0)..(self.data_hora_final_4_dia_2a_chamada || 0))
        _dia = 4
        _segunda_chamada = true
        _data_inicio = self.data_hora_inicial_4_dia_2a_chamada
        _data_final = self.data_hora_final_4_dia_2a_chamada
      when (self.aplicar_2a_chamada_5_dia and (self.data_hora_inicial_5_dia_2a_chamada || 0)..(self.data_hora_final_5_dia_2a_chamada || 0))
        _dia = 5
        _segunda_chamada = true
        _data_inicio = self.data_hora_inicial_5_dia_2a_chamada
        _data_final = self.data_hora_final_5_dia_2a_chamada
      end

      _permite_resposta = true if _dia > 0
    end

    return { permite_resposta: _permite_resposta, dia: _dia, segunda_chamada: _segunda_chamada, data_inicio: _data_inicio, data_final: _data_final  }
  end

  def agendada?
    !self.data_hora_inicial_1_dia.nil?
  end

  def aplicada?
    _retorno = false

    if self.agendada?
      _retorno = (Time.zone.now > (self.data_hora_final_1_dia || 0) and Time.zone.now > (self.data_hora_final_2_dia || 0) and Time.zone.now > (self.data_hora_final_3_dia || 0) and Time.zone.now > (self.data_hora_final_4_dia || 0) and Time.zone.now > (self.data_hora_final_5_dia || 0) and 
                  Time.zone.now > (self.data_hora_final_1_dia_2a_chamada || 0) and Time.zone.now > (self.data_hora_final_2_dia_2a_chamada || 0) and Time.zone.now > (self.data_hora_final_3_dia_2a_chamada || 0) and Time.zone.now > (self.data_hora_final_4_dia_2a_chamada || 0) and Time.zone.now > (self.data_hora_final_5_dia_2a_chamada || 0))
    end
    _retorno
  end

  def corrigida?
    ['concluido', 'liberado'].include?(self.status)
  end

  def avaliacao_resultado_liberado?
    self.status.eql?('liberado')
  end

  def avaliacao_socioemocional?
    (self.turma_avaliacao_alunos.where.not(resultado_analise_personality: nil).count > 0)
  end

  def permite_resposta
    _permite_resposta = false
    _dia = 0
    _segunda_chamada = false
    _data_inicio = nil
    _data_final = nil

    if self.realizado_online
      (1..5).each do |dia_ref|
        if Time.zone.now.between?((self[:"data_hora_inicial_#{dia_ref}_dia"] || 0), (self[:"data_hora_final_#{dia_ref}_dia"] || 0))
          _dia = dia_ref
          _data_inicio = self[:"data_hora_inicial_#{dia_ref}_dia"]
          _data_final = self[:"data_hora_final_#{dia_ref}_dia"]
        end

        if self[:"aplicar_2a_chamada_#{dia_ref}_dia"] and Time.zone.now.between?((self[:"data_hora_inicial_#{dia_ref}_dia_2a_chamada"] || 0), (self[:"data_hora_final_#{dia_ref}_dia_2a_chamada"] || 0))
          _dia = dia_ref
          _data_inicio = self[:"data_hora_inicial_#{dia_ref}_dia_2a_chamada"]
          _data_final = self[:"data_hora_final_#{dia_ref}_dia_2a_chamada"]
          _segunda_chamada = true
        end
      end

      _permite_resposta = true if _dia > 0
    end

    return { permite_resposta: _permite_resposta, dia: _dia, segunda_chamada: _segunda_chamada, data_inicio: _data_inicio, data_final: _data_final  }
  end  

	def roteiro_estudo_nivel_proficiencia(materia_id, avaliacao_conhecimento_questao_id=nil)
		_proficiencia = 0
		_nivel_proficiencia = 'critico'


		_qtde_questoes = avaliacao_conhecimento_questao_id.nil? ? self.avaliacao_conhecimento.avaliacao_conhecimento_questoes.where(materia_id: materia_id).count : 1

		if _qtde_questoes > 0
      if avaliacao_conhecimento_questao_id
			  _proficiencia = self.turma_avaliacao_roteiro_estudos.joins(:avaliacao_conhecimento_questao).where(avaliacao_conhecimento_questoes: {id: avaliacao_conhecimento_questao_id}).average(:percentual_provavel_acerto).to_f
      else
			  _proficiencia = self.turma_avaliacao_roteiro_estudos.joins(:avaliacao_conhecimento_questao).where(avaliacao_conhecimento_questoes: {materia_id: materia_id}).average(:percentual_provavel_acerto).to_f
      end

			_proficiencia = 100 if _proficiencia > 100

			if _proficiencia <= 20.00
				_nivel_proficiencia = 'critico'
			elsif _proficiencia <=  40.00
				_nivel_proficiencia = 'baixo'
			elsif _proficiencia <= 60.00
				_nivel_proficiencia = 'medio'
			elsif _proficiencia <= 80.00
				_nivel_proficiencia = 'alto'
			elsif _proficiencia <= 100.00
				_nivel_proficiencia = 'elevado'
			end	
		end

		return { qtde_questoes: _qtde_questoes, nivel_proficiencia: _nivel_proficiencia, proficiencia: _proficiencia }
	end


end
