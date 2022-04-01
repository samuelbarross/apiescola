class GeneroTextual < ApplicationRecord
  audited on: [:update, :destroy]	

  has_many :proposta_redacoes
end
