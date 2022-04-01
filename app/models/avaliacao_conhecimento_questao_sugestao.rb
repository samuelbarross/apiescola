class AvaliacaoConhecimentoQuestaoSugestao < ApplicationRecord
  belongs_to :avaliacao_conhecimento_questao
  belongs_to :banco_questao
  belongs_to :user, optional: true
  belongs_to :user_nota_professor, class_name: "User", foreign_key: :user_nota_professor_id, optional: true
  
  audited on: [:update, :destroy]

  enum posicao: {
    posicao_a: 1,
    posicao_b: 2,
    posicao_c: 3
 }

end
