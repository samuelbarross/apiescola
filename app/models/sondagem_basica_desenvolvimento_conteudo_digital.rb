class SondagemBasicaDesenvolvimentoConteudoDigital < ApplicationRecord
  belongs_to :sondagem_basica_desenvolvimento

  has_many :registro_navegacoes, dependent: :destroy
  
  audited on: [:update, :destroy]	

  enum tipo: {
    video: 1,
    podcast: 2,
    texto: 3
  }

  def classe_botao_referencia_plano_acao
    _retorno = 'btn btn-default btn-rounded'
    case self.tipo
    when 'video'
      _retorno = 'btn btn-primary btn-rounded'
    when 'podcast'
      _retorno = 'btn btn-success btn-rounded'
    when 'texto'
      _retorno = 'btn btn-warning btn-rounded'
    end

    _retorno
  end

  def icone_botao_referencia_plano_acao
    _retorno = 'fa fa-file'
    case self.tipo
    when 'video'
      _retorno = 'fa fa-video-camera'
    when 'podcast'
      _retorno = 'fa podcast'
    when 'texto'
      _retorno = 'fa fa-file-text-o'
    end

    _retorno
  end

  def icone_representacao
    case self.tipo
    when 'texto'
      _img = "newspaper.svg"
    when 'video'
      _img = "camera-reels.svg"
    when 'podcast'
      _img = "mic.svg"
    end

    _img
  end

end
