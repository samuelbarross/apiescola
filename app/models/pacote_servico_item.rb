class PacoteServicoItem < ApplicationRecord
  belongs_to :pacote_servico
  belongs_to :duvida, optional: true
end
