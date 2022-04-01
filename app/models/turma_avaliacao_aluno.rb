class TurmaAvaliacaoAluno < ApplicationRecord
	belongs_to :turma_avaliacao
	belongs_to :turma_aluno
	belongs_to :curso, optional: true
	belongs_to :user_nota_redacao, class_name: "User", foreign_key: :user_nota_redacao_id, optional: true

	has_many :resultado_plano_acoes, dependent: :destroy
	has_many :turma_avaliacao_aluno_redacoes, dependent: :destroy
	has_many :registro_navegacoes, dependent: :destroy
	has_many :caracteristica_socio_emocionais, dependent: :destroy
	has_many :turma_avaliacao_roteiro_estudos, dependent: :destroy
	has_many :ia_plano_acoes, dependent: :destroy
	has_many :turma_avaliacao_roteiro_estudos, dependent: :destroy

	audited on: [:update, :destroy]	
	
	has_many_attached :files
	has_one_attached :file_redacao
	has_one_attached :plano_acao
	has_one_attached :analise_speck

	enum tipo: {
		padrao: 1,
		desafio: 2,
		extra: 3
	}

	enum lingua_estrangeira: {
		turma_avaliacao_aluno_ingles: 1,
		turma_avaliacao_aluno_espanhol: 2
	}

	enum nota_redacao_fundamental_1: {
		em_desenvolvimento: 1,
		esperado: 2,
		superado: 3,
		fuga_tema: 4
	}

	def presente_avaliacao?
		presente = false
		if self.turma_avaliacao.realizado_online
			presente = (!self.data_abertura_online_1_dia.nil? or !self.data_abertura_online_2_dia.nil? or !self.data_abertura_online_3_dia.nil? or !self.data_abertura_online_4_dia.nil? or !self.data_abertura_online_5_dia.nil?)
		else
			presente = (!self.turma_avaliacao.turma_avaliacao_marcacoes.where(turma_aluno_id: self.turma_aluno_id).first.nil?)
		end

		return presente
	end

	def presente_avaliacao_no_dia?(_dia)
		case _dia
		when 1
			presente = !self.data_abertura_online_1_dia.nil? || !self.data_abertura_online_1_dia_2a_chamada.nil?
		when 2
			presente = !self.data_abertura_online_2_dia.nil? || !self.data_abertura_online_2_dia_2a_chamada.nil?
		when 3
			presente = !self.data_abertura_online_3_dia.nil? || !self.data_abertura_online_3_dia_2a_chamada.nil?
		when 4
			presente = !self.data_abertura_online_4_dia.nil? || !self.data_abertura_online_4_dia_2a_chamada.nil?
		when 5
			presente = !self.data_abertura_online_5_dia.nil? || !self.data_abertura_online_5_dia_2a_chamada.nil?
		else
			presente = false
		end

		return presente
	end

	def presente_avaliacao_redacao?
		presente = !self.data_abertura_redacao_online.nil?
	end

	def entregou_redacao?
		presente = !self.data_gravacao_redacao.nil?
	end

	def redacao_corrigida?
		presente = (!self.nota_redacao.nil? || !self.nota_redacao_fundamental_1.nil?)
	end

	def medias
		menor_nota_linguagens = 0
		maior_nota_linguagens = 0
		media_linguagens = 0

		menor_nota_humanas = 0
		maior_nota_humanas = 0
		media_humanas = 0

		menor_nota_natureza = 0
		maior_nota_natureza = 0
		media_natureza = 0

		menor_nota_matematica = 0
		maior_nota_matematica = 0
		media_matematica = 0

		menor_nota_redacao = 0
		maior_nota_redacao = 0
		media_redacao = 0

		media_geral = 0
		menor_nota_geral = 0

		turma_alunos_participantes = turma_avaliacao.turma_avaliacao_alunos.where('ranking > 0').pluck(:turma_aluno_id)

		turma_avaliacao = self.turma_avaliacao
		case turma_avaliacao.avaliacao_conhecimento.modelo
		when "enem", "avaliacao_inteligente"
			AreaConhecimento.order(:ordem_plano_acao).each do |area_conhecimento|
				if turma_avaliacao.tri_aplicada?
					turma_avaliacao_resultado = turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 6)
																										.where(area_conhecimento_id: area_conhecimento.id)
																										.where(turma_aluno_id: turma_alunos_participantes)
																										.select("coalesce(min(nota_tri), 0) menor_nota, coalesce(max(nota_tri), 0) maior_nota, coalesce(max(case when turma_avaliacao_resultados.turma_aluno_id = #{ self.turma_aluno_id } then turma_avaliacao_resultados.nota_tri else 0 end), 0) as nota")
																										.order(1).first
				else
					turma_avaliacao_resultado = turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 6)
																										.where(area_conhecimento_id: area_conhecimento.id)
																										.where(turma_aluno_id: turma_alunos_participantes)
																										.select("coalesce(min(nota), 0) menor_nota, coalesce(max(nota), 0) maior_nota, coalesce(max(case when turma_avaliacao_resultados.turma_aluno_id = #{ self.turma_aluno_id } then turma_avaliacao_resultados.nota else 0 end), 0) as nota")
																										.order(1).first
				end

				if turma_avaliacao_resultado
					if turma_avaliacao_resultado.nota.eql?(0)
						versao = 1
					else				
						case area_conhecimento.codigo
						when 'A01'
							menor_nota_humanas = 0
							maior_nota_humanas = 0
							media_humanas = turma_avaliacao_resultado.nota
						when 'A02'
							menor_nota_natureza = 0
							maior_nota_natureza = 0
							media_natureza = turma_avaliacao_resultado.nota
						when 'A03'
							menor_nota_redacao = 0
							maior_nota_redacao = 0
							media_redacao = turma_avaliacao_resultado.nota
						when 'A04'
							menor_nota_linguagens = 0
							maior_nota_linguagens = 0
							media_linguagens = turma_avaliacao_resultado.nota
						when 'A05'
							menor_nota_matematica = 0
							maior_nota_matematica = 0
							media_matematica = turma_avaliacao_resultado.nota
						end
					end

					if versao.eql?(1)
						case area_conhecimento.codigo
						when 'A01'
							menor_nota_humanas = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_humanas = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_humanas = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							# media_humanas = turma_avaliacao.turma_avaliacao_resultados.where(turma_aluno_id: self.turma_aluno_id).where(area_conhecimento_id: area_conhecimento.id).where(tipo_registro: 6).first.nota.to_f
							media_humanas = turma_avaliacao_resultado.nota.to_f
						when 'A02'
							menor_nota_natureza = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_natureza = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_natureza = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							media_natureza = turma_avaliacao_resultado.nota.to_f
						when 'A03'
							menor_nota_redacao = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_redacao = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_redacao = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							media_redacao = turma_avaliacao_resultado.nota.to_f
						when 'A04'
							menor_nota_linguagens = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_linguagens = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_linguagens = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							media_linguagens = turma_avaliacao_resultado.nota.to_f
						when 'A05'
							menor_nota_matematica = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_matematica = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_matematica = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							media_matematica = turma_avaliacao_resultado.nota.to_f
						end
					end
				end
			end
			menor_nota_geral = [menor_nota_linguagens, menor_nota_humanas, menor_nota_natureza,menor_nota_matematica].min
			maior_nota_geral = [maior_nota_linguagens, maior_nota_humanas, maior_nota_natureza, maior_nota_matematica].max
			
			unless turma_avaliacao.tri_aplicada?
				nota = (self.nota || 0).to_f
				nota_plano_acao = (self.nota_plano_acao || 0).to_f
			else
				nota = (self.nota_tri || 0).to_f
				nota_plano_acao = (self.nota_tri_pa ||  (self.nota_plano_acao || 0)).to_f
			end

			if nota.eql?(0) and ((media_linguagens + media_humanas + media_natureza + media_matematica).to_f / 4).round(2).to_f > 0
				media_geral = ((media_linguagens + media_humanas + media_natureza + media_matematica).to_f / 4).round(2).to_f
			else
				media_geral = nota
			end


		when "uece"
			AreaConhecimento.order(:ordem_plano_acao).each do |area_conhecimento|
				turma_avaliacao_resultado = turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 6)
																									.where(area_conhecimento_id: area_conhecimento.id)
																									.where(turma_aluno_id: turma_alunos_participantes)
																									.select("coalesce(min(nota), 0) menor_nota, coalesce(max(nota), 0) maior_nota, coalesce(max(case when turma_avaliacao_resultados.turma_aluno_id = #{ self.turma_aluno_id } then turma_avaliacao_resultados.nota else 0 end), 0) as nota")
																									.order(1).first

				if turma_avaliacao_resultado
					if turma_avaliacao_resultado.nota.eql?(0)
						versao = 1
					else				
						case area_conhecimento.codigo
						when 'A01'
							menor_nota_humanas = 0
							maior_nota_humanas = 0
							media_humanas = turma_avaliacao_resultado.nota
						when 'A02'
							menor_nota_natureza = 0
							maior_nota_natureza = 0
							media_natureza = turma_avaliacao_resultado.nota
						when 'A03'
							menor_nota_redacao = 0
							maior_nota_redacao = 0
							media_redacao = turma_avaliacao_resultado.nota
						when 'A04'
							menor_nota_linguagens = 0
							maior_nota_linguagens = 0
							media_linguagens = turma_avaliacao_resultado.nota
						when 'A05'
							menor_nota_matematica = 0
							maior_nota_matematica = 0
							media_matematica = turma_avaliacao_resultado.nota
						end
					end

					if versao.eql?(1)
						case area_conhecimento.codigo
						when 'A01'
							menor_nota_humanas = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_humanas = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_humanas = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							# media_humanas = turma_avaliacao.turma_avaliacao_resultados.where(turma_aluno_id: self.turma_aluno_id).where(area_conhecimento_id: area_conhecimento.id).where(tipo_registro: 6).first.nota.to_f
							media_humanas = turma_avaliacao_resultado.nota.to_f
						when 'A02'
							menor_nota_natureza = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_natureza = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_natureza = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							media_natureza = turma_avaliacao_resultado.nota.to_f
						when 'A03'
							menor_nota_redacao = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_redacao = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_redacao = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							media_redacao = turma_avaliacao_resultado.nota.to_f
						when 'A04'
							menor_nota_linguagens = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_linguagens = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_linguagens = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							media_linguagens = turma_avaliacao_resultado.nota.to_f
						when 'A05'
							menor_nota_matematica = turma_avaliacao_resultado.menor_nota.to_f
							maior_nota_matematica = turma_avaliacao_resultado.maior_nota.to_f

							# Alteração solicitada pelo Felipe em 04/06/2020 - as notas devem ser o aproveitamento % em relação 1000 de cada área de conheccimento
							# media_matematica = ((turma_avaliacao_resultado.menor_nota + turma_avaliacao_resultado.maior_nota) / 2).to_f
							media_matematica = turma_avaliacao_resultado.nota.to_f
						end
					end
				end
			end
			menor_nota_geral = [menor_nota_linguagens, menor_nota_humanas, menor_nota_natureza,menor_nota_matematica].min
			maior_nota_geral = [maior_nota_linguagens, maior_nota_humanas, maior_nota_natureza, maior_nota_matematica].max
			media_geral = ((media_linguagens + media_humanas + media_natureza + media_matematica).to_f / 4).round(2).to_f
			nota = (self.nota || 0).to_f
			nota_plano_acao = (self.nota_plano_acao || 0).to_f

		when "avaliacao_simples"
			nota = (self.nota || 0).to_f
			nota_plano_acao = 0
		end

		medias = {
			menor_nota_linguagens: menor_nota_linguagens, maior_nota_linguagens: maior_nota_linguagens, media_linguagens: media_linguagens,
			menor_nota_humanas: menor_nota_humanas, maior_nota_humanas: maior_nota_humanas, media_humanas: media_humanas,
			menor_nota_natureza: menor_nota_natureza, maior_nota_natureza: maior_nota_natureza, media_natureza: media_natureza,
			menor_nota_matematica: menor_nota_matematica, maior_nota_matematica: maior_nota_matematica, media_matematica: media_matematica,
			menor_nota_redacao: menor_nota_redacao, maior_nota_redacao: maior_nota_redacao, media_redacao: media_redacao,
			media_geral: media_geral, nota: nota, nota_plano_acao: nota_plano_acao
		}				

	end
	
	def questoes_oficiais_plano_acao(area_conhecimento)
		turma_avaliacao = self.turma_avaliacao
		
		turma_avaliacao_lista_adaptadas = turma_avaliacao.turma_avaliacao_lista_adaptadas.where(turma_aluno_id: self.turma_aluno_id).where(area_conhecimento_id: area_conhecimento).where(apresentar_plano_acao: true)
		avaliacao_conhecimento_questoes = AvaliacaoConhecimentoQuestao.where(id: turma_avaliacao_lista_adaptadas.where(area_conhecimento_id: area_conhecimento.id).pluck(:avaliacao_conhecimento_questao_id).uniq)
		avaliacao_conhecimento_questoes = AvaliacaoConhecimentoQuestao.where(id: avaliacao_conhecimento_questoes.pluck(:questao_referencia_id).uniq).order(:numero) if turma_avaliacao.avaliacao_conhecimento.versao.eql? ('versao_1')

		return avaliacao_conhecimento_questoes
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

		turma_avaliacao = self.turma_avaliacao
		case turma_avaliacao.avaliacao_conhecimento.modelo
		when "enem", "avaliacao_inteligente"
			AreaConhecimento.all.order(:ordem_plano_acao).each do |area_conhecimento| 
				turma_avaliacao_resultado = turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 6).where(area_conhecimento_id: area_conhecimento.id).where(turma_aluno_id: self.turma_aluno_id).first
				resultado_plano_acao = self.resultado_plano_acoes.where(area_conhecimento_id: area_conhecimento.id).where(tipo_registro: 1).first
				
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
			
			turma_avaliacao_resultado = turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 3).where(turma_aluno_id: self.turma_aluno_id).first
			media_classica = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
			media_tri = turma_avaliacao_resultado.nota_tri if turma_avaliacao_resultado
			media_tri_pa = turma_avaliacao_resultado.nota_tri_pa if turma_avaliacao_resultado

		when "uece"
			AreaConhecimento.all.order(:ordem_plano_acao).each do |area_conhecimento| 
				turma_avaliacao_resultado = turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 6).where(area_conhecimento_id: area_conhecimento.id).where(turma_aluno_id: self.turma_aluno_id).first
				
				case area_conhecimento.codigo
				when "A01"
					nota_classica_humanas = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
				when "A02"
					nota_classica_natureza = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
				when "A04"
					nota_classica_linguagens = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
				when "A03"
					nota_redacao = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
				when "A05"
					nota_classica_matematica = turma_avaliacao_resultado.nota if turma_avaliacao_resultado
				end
			end  
			
			turma_avaliacao_resultado = turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 3).where(turma_aluno_id: self.turma_aluno_id).first
			media_classica = turma_avaliacao_resultado.nota if turma_avaliacao_resultado

		when "avaliacao_simples"
			media_classica = (self.nota || 0).to_f
		end

    return {
      nota_classica_linguagens: nota_classica_linguagens, nota_classica_humanas: nota_classica_humanas, nota_classica_natureza: nota_classica_natureza, nota_classica_matematica: nota_classica_matematica,
			nota_tri_linguagens: nota_tri_linguagens, nota_tri_humanas: nota_tri_humanas, nota_tri_natureza: nota_tri_natureza, nota_tri_matematica: nota_tri_matematica, 
			nota_tri_linguagens_pa: nota_tri_linguagens_pa, nota_tri_humanas_pa: nota_tri_humanas_pa, nota_tri_natureza_pa: nota_tri_natureza_pa, nota_tri_matematica_pa: nota_tri_matematica_pa, 
			nota_redacao: nota_redacao, media_classica: media_classica, media_tri: media_tri, media_tri_pa: media_tri_pa, 
			percentual_desempenho_pa_linguagens: percentual_desempenho_pa_linguagens, percentual_desempenho_pa_humanas: percentual_desempenho_pa_humanas, percentual_desempenho_pa_natureza: percentual_desempenho_pa_natureza, percentual_desempenho_pa_matematica: percentual_desempenho_pa_matematica
    }
	end
	
	def protocolo_finalizado()
		protocolo_finalizado_1o_dia = self.data_fechamento_online_1_dia.present?
		protocolo_finalizado_2o_dia = self.data_fechamento_online_2_dia.present?
		protocolo_finalizado_3o_dia = self.data_fechamento_online_3_dia.present?
		protocolo_finalizado_4o_dia = self.data_fechamento_online_4_dia.present?
		protocolo_finalizado_5o_dia = self.data_fechamento_online_5_dia.present?

		return  { protocolo_finalizado_1o_dia: protocolo_finalizado_1o_dia, 
							protocolo_finalizado_2o_dia: protocolo_finalizado_2o_dia, 
						 	protocolo_finalizado_3o_dia: protocolo_finalizado_3o_dia, 
						 	protocolo_finalizado_4o_dia: protocolo_finalizado_4o_dia, 
						 	protocolo_finalizado_5o_dia: protocolo_finalizado_5o_dia
		}
	end

	def socioemocional_analisado?
		return (!self.analise_redacao_speck.nil? || !self.analise_redacao_watson.nil? || !self.analise_redacao_maxia.nil?)
	end

	def socioemocional_analizada_por
		_retorno = 'Não Analisado'
		if !self.analise_redacao_speck.nil?
			_retorno = 'speck'
		elsif !self.analise_redacao_watson.nil?
			_retorno = 'ibm-watson'
		elsif !self.analise_redacao_maxia.nil?
			_retorno = 'maxia'
		end

		return _retorno
	end

	def icone_socioemocional
		_icone = 'fa-times text-danger'
		_titulo = 'Não analisada'

		if self.socioemocional_analisado?
			_icone = 'fa-check text-navy'
			_titulo = 'Redação analisada'
		elsif !self.resultado_analise_personality.nil? and !self.resultado_analise_personality.eql?('Processamento concluído.')
			_icone = 'fa fa-exclamation-circle text-danger'
			_titulo = 'Ocorreu erro. Reprocessar'
		elsif (self.texto_redacao || '').split.count <= 300
			_icone = 'fa fa-exclamation-triangle text-warning'
			_titulo = 'Redação com menos de 300 palavras não é analisada'
		end

		# if (self.texto_redacao || '').split.count <= 300
		# 	_icone = 'fa fa-exclamation-triangle text-warning'
		# 	_titulo = 'Redação com menos de 300 palavras não é analisada'
		# elsif self.socioemocional_analisado?
		# 	_icone = 'fa-check text-navy'
		# 	_titulo = 'Redação analisada'
		# elsif !self.resultado_analise_personality.nil? and !self.resultado_analise_personality.eql?('Processamento concluído.')
		# 	_icone = 'fa fa-exclamation-circle text-danger'
		# 	_titulo = 'Ocorreu erro. Reprocessar'
		# end

		return { icone: _icone, titulo: _titulo }
	end

	def redacao_qtde_palavras
		(self.texto_redacao || '').split.count
	end

	def roteiro_estudo_nivel_proficiencia(materia_id)
		_proficiencia = 0
		_nivel_proficiencia = 'critico'

		_qtde_questoes = self.turma_avaliacao_roteiro_estudos.joins(:avaliacao_conhecimento_questao).where(avaliacao_conhecimento_questoes: {materia_id: materia_id}).count
		if _qtde_questoes > 0
			_proficiencia = self.turma_avaliacao_roteiro_estudos.joins(:avaliacao_conhecimento_questao).where(avaliacao_conhecimento_questoes: {materia_id: materia_id}).average(:percentual_provavel_acerto).to_f

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

	def percentual_respostas
	end

	def resultado_geral_acumulado_infantil
		return resultado_infantil_faixa(self.turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 3).where(turma_aluno_id: self.turma_aluno_id).average(:percentual).to_f)
	end

	def resultado_geral_acumulado_infantil_campo_experiencia(_campo_experiencia_id)
		return resultado_infantil_faixa(self.turma_avaliacao.turma_avaliacao_resultados.where(tipo_registro: 4).where(turma_aluno_id: self.turma_aluno_id).where(campo_experiencia_id: _campo_experiencia_id).average(:percentual).to_f)
	end

	def resultado_geral_acumulado_infantil_rubrica(_campo_experiencia_id, _sondagem_basica_desenvolvimento_id)
		_ta = self.turma_aluno
		_item_resposta = _ta.serie_avaliacao_infantil_resultados.joins(serie_avaliacao_infantil: [:avaliacao_conhecimento])
												.where(serie_avaliacao_infantis: {campo_experiencia_id: _campo_experiencia_id})
												.where(serie_avaliacao_infantis: {sondagem_basica_desenvolvimento_id: _sondagem_basica_desenvolvimento_id})
												.where(avaliacao_conhecimentos: {id: self.turma_avaliacao.avaliacao_conhecimento_id}).first.item_resposta

		case _item_resposta
		when 'iniciado'
			return resultado_infantil_faixa(1)
		when 'desenvolvimento'
			return resultado_infantil_faixa(26)
		when 'esperado'
			return resultado_infantil_faixa(51)
		when 'superado'
			return resultado_infantil_faixa(76)
		else
			nil
		end
	end

	def resultado_infantil_faixa(_media)
		_faixa = nil

		if _media <= 25.0
			_faixa = 'Iniciado'
			_classe_cor = 'rlt-black'
		elsif _media <=  50.0
			_faixa = 'Desenvolvendo'
			_classe_cor = 'rlt-info'
		elsif _media <= 75.0
			_faixa = 'Esperado'
			_classe_cor = 'rlt-primary'
		elsif _media <= 100.0
			_faixa = 'Superado'
			_classe_cor = 'rlt-secondary'
		end

		return {faixa: _faixa, classe_cor: _classe_cor, media: _media}
	end	
end