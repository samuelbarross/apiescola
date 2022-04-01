class Produto < ApplicationRecord
  belongs_to :serie
  belongs_to :pessoa

  has_many :escola_produtos, dependent: :destroy

  audited on: [:update, :destroy] 

  validates :nome, :serie_id, presence: true  

	UNRANSACKABLE_ATTRIBUTES = ["created_at", "updated_at", "serie_id", "suplementar"]

	def self.ransackable_attributes auth_object = nil
		(column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
	end  

  has_one_attached :imagem
  

  def preco(pessoa_id, data_referencia, condicao_pagamento_id)
    if condicao_pagamento_id
      condicao_pagamento = CondicaoPagamento.find(condicao_pagamento_id)
    else      
      condicao_pagamento = CondicaoPagamento.where(id: EscolaCondicaoPagamento.where(pessoa_id: pessoa_id).where(ativo: true).pluck(:condicao_pagamento_id).uniq).order(qtde_parcelas: :desc).first
      # condicao_pagamento = CondicaoPagamento.where(qtde_parcelas: 0).first
    end

    _data_referencia = self.escola_produtos
                           .where(pessoa_id: pessoa_id)
                           .where('data_vigencia <= ?', data_referencia.to_date)
                           .where(condicao_pagamento_id: condicao_pagamento.id)
                           .maximum(:data_vigencia)
    if _data_referencia
      preco = self.escola_produtos.where(pessoa_id: pessoa_id).where(data_vigencia: _data_referencia).where(condicao_pagamento_id: condicao_pagamento.id).first.valor
    else
      preco = 0
    end
  end
end
