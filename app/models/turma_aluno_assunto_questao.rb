class TurmaAlunoAssuntoQuestao < ApplicationRecord
  belongs_to :turma_aluno_assunto
  belongs_to :assunto_questao

  audited on: [:update, :destroy]

	enum item_resposta: {
    opcao_a: 1,
    opcao_b: 2,
    opcao_c: 3,
    opcao_d: 4,
    opcao_e: 5,
    sem_resposta: 6,
    resposta_aberta: 7
  }

  
  def letra_resposta
    if self.item_resposta
      self.item_resposta_i18n
    else
      "Sem Resposta"
    end
  end
  
end
