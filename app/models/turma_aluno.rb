class TurmaAluno < ApplicationRecord
	belongs_to :turma
	belongs_to :aluno, class_name: "Pessoa", foreign_key: :pessoa_aluno_id
	belongs_to :curso, optional: true

	has_many :serie_avaliacao_infantil_resultados, dependent: :destroy
	has_many :turma_avaliacao_resultados, dependent: :destroy
	has_many :turma_avaliacao_marcacoes, dependent: :destroy
	has_many :turma_avaliacao_alunos, dependent: :destroy
	has_many :turma_avaliacao_lista_adaptadas, dependent: :destroy
	has_many :turma_aluno_assuntos, dependent: :destroy
	has_many :turma_avaliacao_questao_respostas, dependent: :destroy
	has_many :resultado_plano_acoes, dependent: :destroy
	has_many :ia_plano_acoes, dependent: :destroy
	has_many :turma_avaliacao_roteiro_estudos, dependent: :destroy
	has_many :turma_aluno_indice_proficiencias, dependent: :destroy
	
  audited on: [:update, :destroy]	

	enum status: {
		ativo: 1,
		transferido: 2,
		inativo: 3
	}

	enum lingua_estrangeira: {
		turma_aluno_ingles: 1,
		turma_aluno_espanhol: 2
	}



	def dashboard_itens_versao2(user, _turma_avaliacao_id=nil)
		if _turma_avaliacao_id.nil?
			_a_ciclos = ciclos(user)
		else
			_a_ciclos = [_turma_avaliacao_id]
		end

		_desempenho = desempenho_itens(_a_ciclos, 'itens')

		_oics_avaliados = oics_analisados(_a_ciclos)

		_lacunas = lacunas(_a_ciclos)

		_lacunas_corrigidas = lacunas_corrigidas(_a_ciclos)

		_conteudos_acessados = conteudos_acessados(_a_ciclos)

		_hc_analitica, _hc_media = habilidade_cognitiva(_a_ciclos)


		return { desempenho: _desempenho.to_f, ciclos: _a_ciclos, qtd_ciclos: _a_ciclos.count, qtd_aprendizagem_analisadas: _oics_avaliados.count, qtd_lacunas: _lacunas, perc_probabilidade_correcao: 50, 
						 qtd_aprendizagem_corrigida: _lacunas_corrigidas.count, qtd_conteudo_recomendados: _lacunas * 6, qtd_conteudo_acessados: _conteudos_acessados,
						 habilidade_cognitiva_analitica: _hc_analitica, habilidade_cognitiva_media: _hc_media, qtd_atividades_recomendadas: _lacunas * 2 }

	end

	def ciclos(user)
		if ['admin', 'gestao_vida'].include?(user.perfil)
			turma_avaliacao_alunos = self.turma_avaliacao_alunos
		else
			turma_avaliacao_alunos = self.turma_avaliacao_alunos.joins(:turma_avaliacao)
																	 .where('turma_avaliacoes.data_aplicacao <= ?', Time.zone.now)
		end

		unless self.turma.serie.nivel.codigo.eql?('EI')   #_tipo.eql? ('itens')
			turma_avaliacao_alunos = turma_avaliacao_alunos
																		.joins(turma_avaliacao: [:avaliacao_conhecimento])
																		.where(avaliacao_conhecimentos: {versao: AvaliacaoConhecimento.versoes[:versao_2]})
		else
			turma_avaliacao_alunos = turma_avaliacao_alunos
																		.joins(turma_avaliacao: [:avaliacao_conhecimento])
																		.where(avaliacao_conhecimentos: {modelo: AvaliacaoConhecimento.modelos[:sondagem]})
		end

		turma_avaliacao_alunos = turma_avaliacao_alunos.pluck(:turma_avaliacao_id).uniq
	end

	def desempenho_itens(_a_ciclos, _tipo) #{ _tipo [itens, infantil] }
		TurmaAvaliacaoResultado.joins(turma_avaliacao: [:avaliacao_conhecimento])
						.where(turma_avaliacao_resultados: {turma_avaliacao_id: _a_ciclos})
						.where(avaliacao_conhecimentos: {versao: AvaliacaoConhecimento.versoes[:versao_2]})
						.where(turma_avaliacao_resultados: {turma_aluno_id: self.id})
						.where(turma_avaliacao_resultados: {tipo_registro: 3})
						.average(:percentual)
	end

	def oics_analisados(_a_ciclos)
		self.turma_avaliacao_alunos.joins(turma_avaliacao: [avaliacao_conhecimento: [avaliacao_conhecimento_questoes: [:banco_questao]]])
				.where(turma_avaliacoes: {id: _a_ciclos})
				.where(avaliacao_conhecimentos: {modelo: AvaliacaoConhecimento.modelos[:avaliacao_inteligente], versao: AvaliacaoConhecimento.versoes[:versao_2]})
				.pluck(:'banco_questoes.objeto_conhecimento_habilidade_id').uniq
	end

	def lacunas(_a_ciclos)
		# self.turma_avaliacao_lista_adaptadas
		# 		.where(turma_avaliacao_lista_adaptadas: {turma_avaliacao_id: _a_ciclos, apresentar_plano_acao: true, ativa: true})
		# 		.pluck(:'banco_questoes.avaliacao_conhecimento_questao_id').uniq
		UxMaxia.qtde_lacunas_encontradas( {turma_avaliacao_id: _a_ciclos, turma_aluno_id: self.id, apresentar_plano_acao: true, ativa: true} )
	end

	def lacunas_corrigidas(_a_ciclos)
		self.resultado_plano_acoes
				.where(turma_avaliacao_id: _a_ciclos)
				.where(tipo_registro: 7)
				.where('qtde_itens_respondidos = qtde_itens_corretos')
				.pluck(:objeto_conhecimento_habilidade_id).uniq
	end

	def conteudos_acessados(_a_ciclos)
		UxMaxia.qtde_registro_navegacoes({turma_aluno_id: self.id, tipo_registro_navegacao: [1,5]})
		# self.turma_avaliacao_alunos.joins(:registro_navegacoes).where(turma_avaliacao_alunos: {turma_avaliacao_id: _a_ciclos}).where(registro_navegacoes: {tipo_registro_navegacao: 5}).count
	end

	def lacunas_area_conhecimento(_a_ciclos)
		_resumo = { qtde_linguagens: 0, qtde_humanas: 0, qtde_natureza: 0, qtde_matematica: 0, qtde_total: 0,
								perc_linguagens: 0, perc_humanas: 0, perc_natureza: 0, perc_matematica: 0
							}
		_qtde = 0
		AreaConhecimento.where.not(codigo: 'A03').order(:ordem_plano_acao).each do |area_conhecimento|
			_qtde = self.turma_avaliacao_lista_adaptadas.joins(:banco_questao)
									.where(turma_avaliacao_lista_adaptadas: {turma_avaliacao_id: _a_ciclos, apresentar_plano_acao: true, ativa: true})
									.where(turma_avaliacao_lista_adaptadas: {area_conhecimento_id: area_conhecimento.id})
									.where(area_conhecimento_id: area_conhecimento.id)
									.pluck(:'banco_questoes.objeto_conhecimento_habilidade_id').uniq.count

			case area_conhecimento.codigo
			when 'A04'
				_resumo[:qtde_linguagens] = _qtde
			when 'A01'
				_resumo[:qtde_humanas] = _qtde
			when 'A02'
				_resumo[:qtde_natureza] = _qtde
			when 'A05'
				_resumo[:qtde_matematica] = _qtde
			end

			_resumo[:qtde_total] += _qtde
		end
		
		_resumo[:perc_linguagens] = (_resumo[:qtde_total] > 0 ? (_resumo[:qtde_linguagens].to_f / _resumo[:qtde_total].to_f * 100.0).round(0) : 0)
		_resumo[:perc_humanas] = (_resumo[:qtde_total] > 0 ? (_resumo[:qtde_humanas].to_f / _resumo[:qtde_total].to_f * 100.0).round(0) : 0)
		_resumo[:perc_natureza] = (_resumo[:qtde_total] > 0 ? (_resumo[:qtde_natureza].to_f / _resumo[:qtde_total].to_f * 100.0).round(0) : 0)
		_resumo[:perc_matematica] = (_resumo[:qtde_total] > 0 ? (_resumo[:qtde_matematica].to_f / _resumo[:qtde_total].to_f * 100.0).round(0) : 0)

		_resumo
	end


	def habilidade_cognitiva(_a_ciclos)
		_hc = []
		BloomTaxonomia.order(:codigo).each do |bloom_taxonomia|
			_hc << {codigo: bloom_taxonomia.codigo,
							nome: bloom_taxonomia.nome_dashboard,
							percentual: (self.turma_avaliacao_resultados.where(turma_avaliacao_id: _a_ciclos).where(bloom_taxonomia_id: bloom_taxonomia.id).where(tipo_registro: :resultado_aluno_bloom_taxonomia).average(:percentual) || 0).to_f
			}			
		end

		_hc_media =  (self.turma_avaliacao_resultados.where(turma_avaliacao_id: _a_ciclos).where(tipo_registro: :resultado_aluno_bloom_taxonomia).average(:percentual) || 0).to_f

		return _hc, _hc_media
	end

	def dashboard_infantil_versao2(user, _turma_avaliacao_id=nil)
		if _turma_avaliacao_id.nil?
			_a_ciclos = ciclos(user)
		else
			_a_ciclos = [_turma_avaliacao_id]
		end

		_desemepnho_ciclos = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]

		CampoExperiencia.order(:codigo).each do |campo_experiencia|
			turma_avaliacoes = TurmaAvaliacao.joins(avaliacao_conhecimento: [:ciclo_avaliacao]).where(id: _a_ciclos).order('ciclo_avaliacoes.numero_referencia').each do |turma_avaliacao|
				turma_avaliacao_resultado = turma_avaliacao.turma_avaliacao_resultados.where(turma_aluno_id: self.id).where(campo_experiencia_id: campo_experiencia.id).where(tipo_registro: 4).where.not(status_resultado: nil).first

				if turma_avaliacao_resultado
					_desemepnho_ciclos[campo_experiencia.codigo.to_i][turma_avaliacao.avaliacao_conhecimento.ciclo_avaliacao.numero_referencia.to_i] = turma_avaliacao_resultado.percentual.to_i
				else
					_desemepnho_ciclos[campo_experiencia.codigo.to_i][turma_avaliacao.avaliacao_conhecimento.ciclo_avaliacao.numero_referencia.to_i] = 0
				end
			end
		end

		return { desempenho: _desemepnho_ciclos, ciclos: _a_ciclos }
	end

	def demonstrativo_big8
		_estrategico = calcular_demonstrativo_big8(['facet_adventurousness' , 'facet_imagination' , 'facet_intellect' , 'facet_liberalism' , 'facet_achievement_striving' , 'facet_orderliness' , 'facet_self_discipline' , 'facet_self_efficacy' , 'facet_activity_level' , 'facet_cooperation' , 'facet_morality' , 'facet_trust' , 'facet_self_consciousness'])

    _logico = calcular_demonstrativo_big8(['facet_imagination', 'facet_intellect', 'facet_orderliness', 'facet_self_discipline', 'facet_self_efficacy', 'facet_activity_level', 'facet_excitement_seeking', 'facet_morality', 'facet_trust', 'facet_anxiety', 'facet_depression', 'facet_self_consciousness'])

		_lider = calcular_demonstrativo_big8(['facet_intellect', 'facet_liberalism', 'facet_dutifulness', 'facet_orderliness', 'facet_self_discipline', 'facet_activity_level', 'facet_assertiveness', 'facet_cheerfulness', 'facet_excitement_seeking', 'facet_friendliness', 'facet_gregariousness', 'facet_altruism', 'facet_cooperation', 'facet_morality', 'facet_sympathy', 'facet_trust', 'facet_anger', 'facet_self_consciousness'])

    _inovador = calcular_demonstrativo_big8(['facet_adventurousness', 'facet_artistic_interests', 'facet_emotionality', 'facet_imagination', 'facet_intellect', 'facet_assertiveness', 'facet_excitement_seeking', 'facet_trust', 'facet_anxiety', 'facet_self_consciousness', 'facet_vulnerability'])
		
		_mediador = calcular_demonstrativo_big8(['facet_adventurousness', 'facet_artistic_interests', 'facet_emotionality', 'facet_imagination', 'facet_cautiousness', 'facet_dutifulness', 'facet_cheerfulness', 'facet_friendliness', 'facet_gregariousness', 'facet_altruism', 'facet_cooperation', 'facet_modesty', 'facet_sympathy', 'facet_anxiety', 'facet_depression'])

		_executor = calcular_demonstrativo_big8(['facet_intellect', 'facet_achievement_striving', 'facet_cautiousness', 'facet_dutifulness', 'facet_orderliness', 'facet_self_discipline', 'facet_self_efficacy', 'facet_gregariousness', 'facet_altruism', 'facet_cooperation', 'facet_morality', 'facet_sympathy', 'facet_trust', 'facet_self_consciousness'])
												
		_aventureiro = calcular_demonstrativo_big8(['facet_adventurousness', 'facet_artistic_interests', 'facet_emotionality', 'facet_imagination', 'facet_liberalism', 'facet_activity_level', 'facet_cheerfulness', 'facet_excitement_seeking', 'facet_friendliness', 'facet_gregariousness', 'facet_altruism', 'facet_cooperation', 'facet_sympathy', 'facet_trust', 'facet_self_consciousness'])

		_empreendedor = calcular_demonstrativo_big8(['facet_adventurousness', 'facet_emotionality', 'facet_imagination', 'facet_intellect', 'facet_achievement_striving', 'facet_cautiousness', 'facet_self_discipline', 'facet_self_efficacy', 'facet_activity_level', 'facet_cheerfulness', 'facet_excitement_seeking', 'facet_friendliness', 'facet_gregariousness', 'facet_altruism', 'facet_cooperation', 'facet_morality', 'facet_trust', 'facet_anger', 'facet_anxiety', 'facet_vulnerability'])

		return { estrategico: _estrategico.to_f, logico: _logico.to_f, lider: _lider.to_f , inovador: _inovador.to_f , mediador: _mediador.to_f , executor: _executor.to_f , aventureiro: _aventureiro.to_f , empreendedor: _empreendedor.to_f  }
	end

	def calcular_demonstrativo_big8(_caracteristica_big30)
		(self.turma_avaliacao_alunos.joins(caracteristica_socio_emocionais: [:speck_elemento])
				 .where(speck_elementos: { speck_trait_id: _caracteristica_big30 })
				 .average(:'caracteristica_socio_emocionais.score_analise_maxia') || 0 * 100.0).round(2)
  end	

	def resultado_geral_acumulado_infantil
		return resultado_infantil_faixa(self.turma_avaliacao_resultados.where(tipo_registro: 3).average(:percentual).to_f)
	end

	def resultado_geral_acumulado_infantil_campo_experiencia(_campo_experiencia_id)
		return resultado_infantil_faixa(self.turma_avaliacao_resultados.where(tipo_registro: 4).where(campo_experiencia_id: _campo_experiencia_id).average(:percentual).to_f)
	end

	def resultado_geral_acumulado_infantil_rubrica(_campo_experiencia_id, _sondagem_basica_desenvolvimento_id)
		_item_resposta = self.serie_avaliacao_infantil_resultados.joins(:serie_avaliacao_infantil)
												.where(serie_avaliacao_infantis: {campo_experiencia_id: _campo_experiencia_id})
												.where(serie_avaliacao_infantis: {sondagem_basica_desenvolvimento_id: _sondagem_basica_desenvolvimento_id}).first.item_resposta

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

