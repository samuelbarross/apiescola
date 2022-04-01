class BancoQuestaoLink < ApplicationRecord
  belongs_to :banco_questao

  audited on: [:update, :destroy]	

  validates :banco_questao_id, :tipo_link, presence: true
  validates :endereco_url, presence: true, if: :obrigatorio_url?
  validates :descricao, presence: true, if: :obrigatorio_descricao?

  enum tipo_link: {
		site: 1,
		video: 2,
    podcast: 3,
    livro: 4,
    filme: 5,
    video_longo: 6,
    resumo: 7,
    mapa_mental: 8,
    texto: 9
  }

  def obrigatorio_url?
    ['site', 'video', 'podcast'].include?(self.tipo_link)
  end

  def obrigatorio_descricao?
    ['indicacao_filme', 'indicacao_livro', 'site', 'podcast'].include?(self.tipo_link)
  end  
end
