class TurmaAvaliacaoResultado < ApplicationRecord
  belongs_to :turma_avaliacao
  belongs_to :turma_avaliacao_aluno, optional: true
  belongs_to :campo_experiencia, optional: true
  belongs_to :sondagem_basica_desenvolvimento, optional: true
  belongs_to :turma_aluno, optional: true
  belongs_to :area_conhecimento, optional: true
  belongs_to :competencia, optional: true
  belongs_to :habilidade, optional: true
  belongs_to :disciplina, optional: true
  belongs_to :assunto, optional: true
  belongs_to :bloom_taxonomia, optional: true
  belongs_to :materia, optional: true

  audited on: [:update, :destroy]
  
  enum tipo_registro: {
    resultado_turma: 1,
    resultado_turma_campo_experiencia: 2,
    resultado_aluno: 3,
    resultado_aluno_campo_experiencia: 4,
    resultado_turma_sondagem_basica_desenvolvimento: 5,
    resultado_aluno_area_conhecimento: 6,
    resultado_aluno_habilidade: 7,
    resultado_turma_area_conhecimento: 8,
    resultado_turma_habilidade: 9,
    resultado_turma_competencia: 10,
    resultado_aluno_bloom_taxonomia: 11,
    resultado_aluno_disciplina: 12,
    resultado_aluno_assuntos: 13,
    resultado_aluno_materia: 14,
    resultado_turma_materia: 15,
    resultado_aluno_oic_habilidade: 16
  }

  enum status_resultado: {
    rubrica_iniciado: 1,
    rubrica_em_desenvolvimento: 2,
    rubrica_esperado: 3,
    rubrica_superado: 4
  }


  def classe_faixas_ensino_infantil
    _faixas = { 
      iniciado: 'faixa_ensino_infantil-btn-Nao',
      em_desenvolvimento: 'faixa_ensino_infantil-btn-Nao',
      esperado: 'faixa_ensino_infantil-btn-Nao',
      superado: 'faixa_ensino_infantil-btn-Nao'
    }

    case self.status_resultado
    when 'rubrica_iniciado'
      _faixas[:iniciado] = 'faixa_ensino_infantil-btn-Ini'
    when 'rubrica_em_desenvolvimento'
      _faixas[:em_desenvolvimento] = 'faixa_ensino_infantil-btn-Des'
    when 'rubrica_esperado'
      _faixas[:esperado] = 'faixa_ensino_infantil-btn-Esp'
    when 'rubrica_superado'
      _faixas[:superado] = 'faixa_ensino_infantil-btn-Sup'
    end
    
    return _faixas
  end

end
