class RegistroNavegacao < ApplicationRecord
  belongs_to :turma_avaliacao
  belongs_to :turma_avaliacao_aluno, optional: true
  belongs_to :objeto_conhecimento_conteudo_digital, optional: true
  belongs_to :avaliacao_conhecimento_questao, optional: true
  belongs_to :sondagem_basica_desenvolvimento_atividade, optional: true
  belongs_to :sondagem_basica_desenvolvimento_conteudo_digital, optional: true

  audited on: [:update, :destroy]

  enum tipo_registro_navegacao: {
    acesso_plano_acao: 1,
    download_plano_acao: 2,
    acesso_responder_plano_acao: 3,
    link_plano_acao: 4,
    conteudo_digital_oic_plano_acao: 5,    #plano_acao
    conteudo_digital_oic_roteiro_estudo: 6,
    acesso_roteiro_estudo: 7,
    recomendacao_conteudo: 8
  }

end
