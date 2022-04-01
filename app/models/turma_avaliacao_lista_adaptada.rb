class TurmaAvaliacaoListaAdaptada < ApplicationRecord
  belongs_to :turma_avaliacao
  belongs_to :disciplina, optional: true
  belongs_to :turma_aluno, optional: true
  belongs_to :avaliacao_conhecimento_questao
  belongs_to :area_conhecimento, optional: true
  belongs_to :bloom_taxonomia, optional: true
  belongs_to :assunto, optional: true
  belongs_to :banco_questao, optional: true
  belongs_to :materia, optional: true

  audited on: [:update, :destroy]
  
  enum tipo_lista: {
    lista_habilidade_aluno: 1,
    lista_habilidade_disciplina: 2
  }

	enum item_resposta: {
    opcao_a: 1,
    opcao_b: 2,
    opcao_c: 3,
    opcao_d: 4,
    opcao_e: 5,
    sem_resposta: 6
  }


  def letra_resposta
    _retorno = 'SR'
    if self.item_resposta 
      _retorno = self.item_resposta_i18n unless self.read_attribute_before_type_cast(:item_resposta).eql?(TurmaAvaliacaoListaAdaptada.item_respostas[:sem_resposta])
    end

    _retorno
  end
end
