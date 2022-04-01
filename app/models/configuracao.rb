class Configuracao < ApplicationRecord
  belongs_to :ano_letivo
  belongs_to :ecommerce_ano_letivo, class_name: "AnoLetivo", foreign_key: :ecommerce_ano_letivo_id, optional: true 

  audited on: [:update, :destroy]

  has_one_attached :oic

  enum integracao_socio_emocional: {
    socioemocional_speck: 1,
    socioemocional_ibm_watson: 2,
    socioemocional_ambos: 3,
    socioemocional_maxia: 4
  }

  enum versao_banco: { 
    teste: 1,
    experiencia: 2,
    producao: 3
   }

end
