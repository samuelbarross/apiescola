class IaPlanoAcaoItem < ApplicationRecord
  belongs_to :ia_plano_acao_oic
  belongs_to :banco_questao
end
