class PacoteServicoPreco < ApplicationRecord

  enum servico: { 
    tira_duvida: 1,
    aula: 2
   }
     
end
