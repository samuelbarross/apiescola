class CupomDesconto < ApplicationRecord
  include Friendlyable

  belongs_to :user
  belongs_to :pessoa

  has_many :pedido_vendas, dependent: :destroy

  audited on: [:update, :destroy]
  
  validates :valor, presence: true
end
