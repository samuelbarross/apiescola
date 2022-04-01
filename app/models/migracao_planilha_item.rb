class MigracaoPlanilhaItem < ApplicationRecord
  belongs_to :pessoa, optional: true
  belongs_to :migracao_planilha
end
