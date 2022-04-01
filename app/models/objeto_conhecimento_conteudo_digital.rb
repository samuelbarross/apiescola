class ObjetoConhecimentoConteudoDigital < ApplicationRecord
  belongs_to :objeto_conhecimento

  has_many :conteudo_digital_series, dependent: :destroy
  has_many :registro_navegacoes, dependent: :destroy

  audited on: [:update, :destroy]

  accepts_nested_attributes_for :conteudo_digital_series, :allow_destroy => true

  enum tipo: {
		site: 1,
		video: 2,
		podcast: 3,
    mapa_mental: 4,
    artigo_pedagogico: 5,
    jogo_educativo: 6,
    pea: 7,
    atividade_embasamento: 8
  }

  enum duracao_video: {
    video_muito_curto: 1,
    video_curto: 2,
    video_regular: 3,
    video_longo: 4,
    video_muito_longo: 5
  }

  enum tamanho_texto: {
    texto_muito_curto: 1,
    texto_curto: 2,
    texto_regular: 3,
    texto_longo: 4,
    texto_muito_longo: 5
  }

  enum forma: {
    sintetizado: 1,
    detalhado: 2
  }

  enum plataforma: {
    plataforma_youtube: 1,
    plataforma_igtv: 2,
    plataforma_tiktok: 3,
    plataforma_spotify: 4,
    plataforma_amazon: 5,
    plataforma_deezer: 6,
    plataforma_site: 7
  }

  enum recurso: {
    lousa: 1,
    slide: 2,
    escrita_papel: 3,
    animacao: 4,
    sem_recurso: 5
  }

  enum tipo_atividade_embasamento: {
    atividade_artigo_pedagogico: 1,
    atividade_video: 2
  }

  enum nivel_atividade_embasamento: {
    nivel_basico: 1,
    nivel_medio: 2,
    nivel_aprofundamento: 3
  }

  def minutos_formatado
    self.tempo_duracao_minutos.to_s.rjust(2, '0')
  end

  def segundos_formatado
    self.tempo_duracao_segundos.to_s.rjust(2, '0')
  end

  def referencia_ia
    case self.tipo
    when 'video'
      if self.recurso.present? and self.duracao_video.present?
        _retorno = {
          type: "video",
          resource: (['lousa','slide','escrita_papel'].include?(self.recurso) ? 'RC' : (self.recurso.eql?('animacao') ? 'RNC' : 'SR' ) ),
          duration: (['video_muito_curto', 'video_curto', 'video_regular'].include?(self.duracao_video) ? 'DC' : 'DL' ),
          id: self.id
        }
      end
    when 'podcast'
      if self.duracao_video.present?
        _retorno = {
          type: "podcast",
          size: ['MC', 'C', 'R', 'L', 'ML'][ObjetoConhecimentoConteudoDigital.duracao_videos[:"#{self.duracao_video}"]-1],
          id: self.id
        }
      end
    when 'artigo_pedagogico'
      if self.tamanho_texto.present?
        _retorno = {
          type: "artigo",
          size: ['MC', 'C', 'R', 'L', 'ML'][ObjetoConhecimentoConteudoDigital.tamanho_textos[:"#{self.tamanho_texto}"]-1],
          id: self.id
        }
      end
    when 'mapa_mental'
      if self.forma.present?
        _retorno = {
          type: "mapa_mental",
          level: ['S', 'C'][ObjetoConhecimentoConteudoDigital.formas[:"#{self.forma}"]-1],
          id: self.id
        }
      end
    when 'atividade_embasamento'
      if self.tipo_atividade_embasamento.present? and self.nivel_atividade_embasamento.present?
        _retorno = {
          type: "lista_exercicio",
          kind: ['TA', 'TV'][ObjetoConhecimentoConteudoDigital.tipo_atividade_embasamentos[:"#{self.tipo_atividade_embasamento}"]-1],
          level: ['NB', 'NM', 'ND'][ObjetoConhecimentoConteudoDigital.nivel_atividade_embasamentos[:"#{self.nivel_atividade_embasamento}"]-1],
          id: self.id
        }
      end
    # else
    #   _retorno = {
    #     type: "inexistente",
    #     id: self.id
    #   }
    end

    _retorno
  end

  def icone_representacao
    case self.tipo
    when 'site'
      _img = "layout-wtf.svg"
    when 'video'
      _img = "camera-reels.svg"
    when 'podcast'
      _img = "mic.svg"
    when 'mapa_mental'
      _img = "diagram-3.svg"
    when 'artigo_pedagogico'
      _img = "newspaper.svg"
    when 'jogo_educativo'
      _img = "controller.svg"
    when 'pea'
      _img = "diagram-3.svg"
    when 'atividade_embasamento'
      _img = "book.svg"
    end

    _img
  end


end
