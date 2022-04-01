class AssuntoSerie < ApplicationRecord
  belongs_to :assunto
  belongs_to :serie

  has_many :assunto_questoes, dependent: :destroy
  has_many :assunto_links, dependent: :destroy

  audited on: [:update, :destroy]

  has_one_attached :conteudo_intensivo
  has_one_attached :conteudo_7v
  has_one_attached :conteudo_14v

  accepts_nested_attributes_for :assunto_links, :allow_destroy => true
  
end
