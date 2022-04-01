class CaracteristicaSocioEmocional < ApplicationRecord
  belongs_to :speck_elemento
  belongs_to :pessoa
  belongs_to :speck_elemento
  belongs_to :turma_avaliacao_aluno, optional: true
  
  audited on: [:update, :destroy]

  enum faixa: {
    faixa_muito_baixo: 1,
    faixa_baixo: 2,
    faixa_medio: 3,
    faixa_alto: 4,
    faixa_muito_alto: 5
  }
  

  def classe_css_relatorio_maxia_personality
    _faixa_muito_baixo = 'relat-btn relat-btn-pink-1'
    _faixa_baixo = 'relat-btn relat-btn-pink-2'
    _faixa_medio = 'relat-btn relat-btn-purple'
    _faixa_alto = 'relat-btn relat-btn-blue-1'
    _faixa_muito_alto = 'relat-btn relat-btn-blue-2'
    _botao_branco = 'relat-btn-gray-stroke'

    case self.faixa
    when 'faixa_muito_baixo'
      _retorno = [ _faixa_muito_baixo, _botao_branco, _botao_branco, _botao_branco, _botao_branco ]
    when 'faixa_baixo'
      _retorno = [ _botao_branco, _faixa_baixo, _botao_branco, _botao_branco, _botao_branco ]
    when 'faixa_medio'
      _retorno = [ _botao_branco, _botao_branco, _faixa_medio, _botao_branco, _botao_branco ]
    when 'faixa_alto'
      _retorno = [ _botao_branco, _botao_branco, _botao_branco, _faixa_alto, _botao_branco ]
    when 'faixa_muito_alto'
      _retorno = [ _botao_branco, _botao_branco, _botao_branco, _botao_branco, _faixa_muito_alto ]
    end

    return _retorno
  end


end
