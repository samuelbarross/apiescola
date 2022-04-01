class AssuntoLink < ApplicationRecord
  belongs_to :assunto, optional: true
  belongs_to :assunto_serie, optional: true

  audited on: [:update, :destroy]

  validates :tipo, presence: true
  validates :endereco_url, presence: true, if: :obrigatorio_url?
  validates :descricao, presence: true, if: :obrigatorio_descricao?
  
  enum tipo: {
		site: 1,
		video: 2,
		podcast: 3,
    link_assunto: 4,
    link_complementar: 5,
    filme: 6,
    livro: 7
  }

  def obrigatorio_url?
    ['site', 'video', 'podcast', 'link_assunto', 'link_complementar'].include?(self.tipo)
  end

  def obrigatorio_descricao?
    ['filme', 'livro'].include?(self.tipo)
  end
end
