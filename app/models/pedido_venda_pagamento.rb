class PedidoVendaPagamento < ApplicationRecord
  belongs_to :pedido_venda
  belongs_to :condicao_pagamento
  belongs_to :esitef_payment, optional: true
  belongs_to :user_confirmacao_manual, class_name: "User", foreign_key: "user_confirmacao_manual_id", optional: true

  after_save :atualizar_situacao_pedido
  
  audited on: [:update, :destroy]

  has_one_attached :comprovante

  validates :pedido_venda_id, :condicao_pagamento_id, :valor, presence: true
  validates :numero_cartao, :nome_cartao, :validade_cartao, :codigo_seguranca_cartao, presence: true, if: :pagamento_cartao_credito?
  validate :pagamento_valido?
  # validate :comprovante, if: :pagamento_transferencia_bancaria?

  enum forma_pagamento: {
    cartao_credito: 1,
    transferencia_bancaria: 2
  }

  def pagamento_cartao_credito?
    self.forma_pagamento.eql?('cartao_credito')
  end


  def atualizar_situacao_pedido
    pedido_venda = self.pedido_venda
    pedido_venda.atualizar_situacao
  end

  def pagamento_valido?
    pagamento_valido = true

    case self.forma_pagamento
    when 'transferencia_bancaria'
      if !self.comprovante.attached?
        self.errors.add(:comprovante, ' não anexado.')
        pagamento_valido = false
      end

    when 'cartao_credito'
      if self.numero_cartao.present?
        self.numero_cartao = self.numero_cartao.scan(/\d/).join.gsub(/(\d{4})(\d{4})(\d{4})(\d{4})/, "\\1-\\2-\\3-\\4")
        unless self.numero_cartao.size.eql?(19)
          self.errors.add(:numero_cartao, 'Problema com a quantidade de dígitos ....  Formato correto é 9999.9999.9999.9999')
          pagamento_valido = false
        end
      end

      if self.validade_cartao.present? 
        self.validade_cartao = self.validade_cartao.scan(/\d/).join.gsub(/(\d{2})(\d{2})/, "\\1/\\2")

        unless self.validade_cartao.size.eql?(5)
          self.errors.add(:validade_cartao, 'Problema com a quantidade de dígitos....  Formato correto é MM/AA')
          pagamento_valido = false
        end
      end

      if self.codigo_seguranca_cartao.present?
        unless self.codigo_seguranca_cartao.to_i > 0
          self.errors.add(:codigo_seguranca_cartao, ' deve ser numérico....')
          pagamento_valido = false
        end
        unless [3,4].include?(self.codigo_seguranca_cartao.size)
          self.errors.add(:codigo_seguranca_cartao, ' tem problema com a quantidade de dígitos....')
          pagamento_valido = false
        end
      end
    end
    
    pagamento_valido
  end

  def numero_cartao_exibicao
    unless self.numero_cartao.nil? 
      self.numero_cartao.scan(/\d/).join.gsub(/(\d{4})(\d{4})(\d{4})(\d{4})/, "\\1-****-****-\\4")
    else
      ''
    end
  end

  def validade_cartao_exibicao
    unless self.validade_cartao.nil?
      self.validade_cartao.scan(/\d/).join.gsub(/(\d{2})(\d{2})/, "**/**")
    else
      ''
    end
  end

  def codigo_seguranca_cartao_exibicao
    unless self.validade_cartao.nil?
      "***"
    else
      ''
    end
  end

end
