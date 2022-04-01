class SondagemBasicaDesenvolvimentoAtividadeLink < ApplicationRecord
  belongs_to :sondagem_basica_desenvolvimento_atividade

  audited on: [:update, :destroy]	
end
