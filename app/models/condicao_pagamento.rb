class CondicaoPagamento < ApplicationRecord
  has_many :escola_condicao_pagamentos, dependent: :destroy
  has_many :escola_produtos, dependent: :destroy
  
  audited on: [:update, :destroy]
    
  validates :descricao, :qtde_parcelas, presence: true  
end
