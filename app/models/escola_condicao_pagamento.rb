class EscolaCondicaoPagamento < ApplicationRecord
  belongs_to :condicao_pagamento
  belongs_to :pessoa

  audited on: [:update, :destroy]
end
