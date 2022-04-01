class EsitefPayment < ApplicationRecord
  belongs_to :user, optional: true
  
  has_many :pedido_venda_pagamentos, dependent: :destroy

  audited on: [:update, :destroy]	
end
