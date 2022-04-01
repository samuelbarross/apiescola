class TurmaAvaliacaoQuestaoResposta < ApplicationRecord
	belongs_to :turma_avaliacao_questao
  belongs_to :turma_aluno
  belongs_to :turma_avaliacao
  belongs_to :avaliacao_conhecimento_questao, optional: true
  
	audited on: [:update, :destroy]

	enum item_resposta: {
    opcao_a: 1,
    opcao_b: 2,
    opcao_c: 3,
    opcao_d: 4,
    opcao_e: 5,
    sem_resposta: 6
  }

  enum item_resposta_online: {
    opcao_online_a: 1,
    opcao_online_b: 2,
    opcao_online_c: 3,
    opcao_online_d: 4,
    opcao_online_e: 5,
    sem_resposta_online: 6
  }

  

  def letra_resposta
    if self.item_resposta
      self.item_resposta_i18n
    else
      "Sem Resposta"
    end
  end

  def letra_resposta_online
    if self.item_resposta_online
      self.item_resposta_online_i18n
    else
      "Sem Resposta"
    end
  end

  def sigla_resposta_online
    if self.item_resposta_online
      self.item_resposta_online_i18n
    else
      "SR"
    end
  end

end
