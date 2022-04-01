class PedidoVenda < ApplicationRecord
  belongs_to :pessoa
  belongs_to :serie
  belongs_to :user
  belongs_to :pessoa_comprador, class_name: "Pessoa", foreign_key: :pessoa_comprador_id, optional: true
  belongs_to :cupom_desconto, optional: true
  belongs_to :ano_letivo, optional: true

  has_many :pedido_venda_itens, dependent: :destroy
  has_many :pedido_venda_pagamentos, dependent: :destroy
  has_many :pedido_venda_ocorrencias, dependent: :destroy

  audited on: [:update, :destroy]

  validates :pessoa_id, :serie_id, :data_emissao, :nome_aluno, presence: true
  validate :cupom_desconto_valido

  has_many_attached :anexos  

  enum situacao: {
    ativo: 1,
    aguardando_pagamento: 2,
    pagamento_realizado: 3,
    entregue_vida: 4,
    cancelado: 5,
    entregue_aluno: 6,
    aguardando_confirmacao_pagamento: 7
  }

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "pessoa_id", "serie_id"]

	def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end
  
  def valor_total
    valor_total = (self.pedido_venda_itens.sum('valor_unitario * quantidade') || 0)
    valor_total = valor_total - self.cupom_desconto.valor if self.cupom_desconto_id
    valor_total
  end
  
  def valor_total_itens
    valor_total = (self.pedido_venda_itens.sum('valor_unitario * quantidade') || 0)
    valor_total
  end

  def valor_pago
    self.pedido_venda_pagamentos.sum(:valor)
  end

  def atualizar_situacao
    unless ['cancelado', 'entregue'].include?(self.situacao)
      if self.valor_total.eql?(0) 
        self.update!(situacao: :ativo)
      else
        if (self.valor_total > self.valor_pago) 
          self.update!(situacao: :aguardando_pagamento)
        else          
          if self.pedido_venda_pagamentos.count.eql?(self.pedido_venda_pagamentos.where(forma_pagamento: :cartao_credito).where(cartao_autorizado: true).count)
            self.update!(situacao: :pagamento_realizado)
          elsif self.pedido_venda_pagamentos.count.eql?(self.pedido_venda_pagamentos.where(forma_pagamento: :cartao_credito).where(cartao_autorizado: nil).count)
            self.update!(situacao: :aguardando_confirmacao_pagamento)
          elsif self.pedido_venda_pagamentos.count.eql?(self.pedido_venda_pagamentos.where(forma_pagamento: :transferencia_bancaria).where(confirmacao_manual: true).with_attached_comprovante.count)
            self.update!(situacao: :pagamento_realizado)
          elsif self.pedido_venda_pagamentos.count.eql?(self.pedido_venda_pagamentos.where(forma_pagamento: :transferencia_bancaria).with_attached_comprovante.count)
            self.update!(situacao: :aguardando_confirmacao_pagamento)
          end
        end
      end
    end
  end

  def cupom_desconto_valido
    cupom_desconto_valido = true
    
    if self.codigo_cupom_desconto.present?
      cupom_desconto = CupomDesconto.find_by_hash_id(self.codigo_cupom_desconto)
      unless cupom_desconto.nil?
        if cupom_desconto.pedido_vendas.where.not(id: self.id).count > 0 
          errors.add(:codigo_cupom_desconto, ' já utilizado em outro pedido.')
          cupom_desconto_valido = false      
        else
          self.cupom_desconto_id = cupom_desconto.id
        end
      else
        errors.add(:codigo_cupom_desconto, ' não existe.')
        cupom_desconto_valido = false
      end
    else
      self.cupom_desconto_id = nil
    end

    cupom_desconto_valido
  end

end
