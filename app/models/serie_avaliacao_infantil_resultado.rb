class SerieAvaliacaoInfantilResultado < ApplicationRecord
  belongs_to :turma_aluno
  belongs_to :serie_avaliacao_infantil
  belongs_to :turma_avaliacao

  audited on: [:update, :destroy]

  has_many_attached :anexos

  enum item_resposta: {
    iniciado: 1,
    desenvolvimento: 2,
    esperado: 3,
    superado: 4
  }

  enum item_resposta_familia: {
    familia_iniciado: 1,
    familia_desenvolvimento: 2,
    familia_esperado: 3,
    familia_superado: 4
  }

  def classe_faixas
    _faixas = { 
      iniciado: 'faixa_ensino_infantil-btn-Nao',
      em_desenvolvimento: 'faixa_ensino_infantil-btn-Nao',
      esperado: 'faixa_ensino_infantil-btn-Nao',
      superado: 'faixa_ensino_infantil-btn-Nao'
    }

    case self.item_resposta
    when 'iniciado'
      _faixas[:iniciado] = 'faixa_ensino_infantil-btn-Ini'
    when 'desenvolvimento'
      _faixas[:em_desenvolvimento] = 'faixa_ensino_infantil-btn-Des'
    when 'esperado'
      _faixas[:esperado] = 'faixa_ensino_infantil-btn-Esp'
    when 'superado'
      _faixas[:superado] = 'faixa_ensino_infantil-btn-Sup'
    end
    
    return _faixas
  end

end
