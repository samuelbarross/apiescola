class ConteudoDigitalSerie < ApplicationRecord
  belongs_to :objeto_conhecimento_conteudo_digital
  belongs_to :serie

  audited on: [:update, :destroy]
  
end
