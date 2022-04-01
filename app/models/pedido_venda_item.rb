class PedidoVendaItem < ApplicationRecord
  belongs_to :pedido_venda
  belongs_to :produto

  audited on: [:update, :destroy]

  validates :pedido_venda_id, :produto_id, :quantidade, :valor_unitario, presence: true  
end
