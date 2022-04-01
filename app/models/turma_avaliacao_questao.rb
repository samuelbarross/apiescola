class TurmaAvaliacaoQuestao < ApplicationRecord
	belongs_to :turma_avaliacao
	belongs_to :banco_questao, optional: true
	belongs_to :avaliacao_conhecimento_questao, optional: true

	has_many :turma_avaliacao_questao_respostas, dependent: :destroy

  audited on: [:update, :destroy]	

	def respondida(turma_aluno_id)
		return ['opcao_online_a', 'opcao_online_b', 'opcao_online_c', 'opcao_online_d', 'opcao_online_e'].include?(self.turma_avaliacao_questao_respostas.where(turma_aluno_id: turma_aluno_id).first.item_resposta_online)
	end
end
