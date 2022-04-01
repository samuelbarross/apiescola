class PedidoVendaOcorrencia < ApplicationRecord
  belongs_to :pedido_venda
  belongs_to :user

  audited on: [:update, :destroy]

  enum grupo: {
    atendimento_cliente: 1,
    cobranca: 2,
    comercial: 3
  }

  enum meio_contato: {
    apontamento_ocorrencia: 1,
    telefone: 2,
    email: 3,
    presencial: 4
  }

  validates :data_referencia, :grupo, :descricao, :meio_contato, presence: true


  def classe_label
    case self.grupo
    when 'atendimento_cliente'
      'label label-primary'
    when 'cobranca'
      'label label-warning'
    when 'comercial'
      'label label-success'
    end
  end

  def fa_icone
    case self.meio_contato
    when 'apontamento_ocorrencia'
      'fa fa-file'
    when 'telefone'
      'fa fa-phone'
    when 'email'
      'fa fa-envelope'
    when 'presencial'
      'fa fa-user-md'
    end    
  end

end
