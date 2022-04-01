class GestaoAvaliacaoQuestaoResposta < ApplicationRecord
  belongs_to :gestao_avaliacao
  belongs_to :gestao_avaliacao_pessoa
  belongs_to :avaliacao_conhecimento_questao
  belongs_to :pessoa
end
