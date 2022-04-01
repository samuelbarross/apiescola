class BancoQuestao < ApplicationRecord
	belongs_to :habilidade, optional: true
	belongs_to :objeto_conhecimento_habilidade
	belongs_to :user, optional: true
	belongs_to :pessoa, optional: true

	has_many :turma_avaliacao_questoes
	has_many :avaliacao_conhecimento_questoes
	has_many :banco_questao_links, dependent: :destroy
	has_many :banco_questao_series, dependent: :destroy
	has_many :banco_questao_revisoes, dependent: :destroy
	has_many :banco_questao_materias, dependent: :destroy
	has_many :turma_avaliacao_lista_adaptadas
	has_many :ia_plano_acao_itens

	audited on: [:update, :destroy]
	
  has_one_attached :imagem_enunciado
  has_one_attached :imagem_comentario
  has_one_attached :anexo_auxiliar

	accepts_nested_attributes_for :banco_questao_links, :allow_destroy => true
	accepts_nested_attributes_for :banco_questao_series, :allow_destroy => true
	accepts_nested_attributes_for :banco_questao_materias, :allow_destroy => true
    
	enum nivel_dificuldade: {
		baixa: 1,
		media: 2,
		alta: 3
	}

	validates :gabarito, :comentario, :qtde_itens_resposta, presence: true

  enum gabarito: {
    opcao_a: 1,
    opcao_b: 2,
    opcao_c: 3,
    opcao_d: 4,
    opcao_e: 5
	}

  enum qtde_itens_resposta: {
    a_b_c_d_e: 1,
    a_b_c_d: 2
	}

	enum status: {
		ativa: 1,
		revisao: 2,
		aprovada: 3,
		inativa: 4
	}

  def classe_span_status
    classe = "label label-danger"

    case self.status
    when 'ativa'
      classe = "label label-danger"
    when 'revisao'
      classe = "label label-warning"
    when 'aprovada'
			classe = "label label-primary"
    when 'inativa'
      classe = "label label-muted"			
    end

    classe
  end	

  def letra_gabarito
    if self.gabarito
      self.gabarito_i18n
    else
      "SR"
    end
  end

  def parametros_logisticos(serie_id)
    # _parametro_tri_b = 0

    # if self.parametro_tri_a.nil? or ([0, 2].include?(self.parametro_tri_a) and [0, 0.2].include?(self.parametro_tri_b))
    #   turma_avaliacao_questao = self.avaliacao_conhecimento_questoes
    #                                 .joins(:turma_avaliacao_questoes)
    #                                 .where.not(turma_avaliacao_questoes: {parametro_tri_a: nil})
    #                                 .where.not(turma_avaliacao_questoes: {parametro_tri_a: 0}).first
    #   if turma_avaliacao_questao
    #     self.update_columns(parametro_tri_a: turma_avaliacao_questao.parametro_tri_a, parametro_tri_b: turma_avaliacao_questao.parametro_tri_b, parametro_tri_c: turma_avaliacao_questao.parametro_tri_c)
    #     _parametro_tri_b = self.parametro_tri_b
    #   else
    #     self.update_columns(parametro_tri_a: 2, parametro_tri_c: 0.2)

    #     case self.banco_questao_series.find_by_serie_id(serie_id).nivel_dificuldade
    #     when 'baixa'
    #       _parametro_tri_b = -1
    #     when 'media'
    #       _parametro_tri_b = 0
    #     when 'alta'
    #       _parametro_tri_b = 1
    #     end
    #   end
    # else
    #   _parametro_tri_b = self.parametro_tri_b
    # end

    # return { parametro_tri_a: self.parametro_tri_a.to_f, parametro_tri_b: _parametro_tri_b.to_f, parametro_tri_c: self.parametro_tri_c.to_f }
    
    return { parametro_tri_a: self.parametro_tri_a.to_f, parametro_tri_b: self.parametro_tri_b.to_f, parametro_tri_c: self.parametro_tri_c.to_f }
  end
		
end
