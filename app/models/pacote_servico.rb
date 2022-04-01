class PacoteServico < ApplicationRecord
  belongs_to :user

  has_many :pacote_servico_itens

  enum servico: { 
    tira_duvida: 1,
    aula: 2
   }
end
