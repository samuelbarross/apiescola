class SondagemBasicaDesenvolvimentoAtividade < ApplicationRecord
  belongs_to :sondagem_basica_desenvolvimento

  has_many :registro_navegacoes, dependent: :destroy
  has_many :sondagem_basica_desenvolvimento_atividade_links, dependent: :destroy

  audited on: [:update, :destroy]	

  validates :sondagem_basica_desenvolvimento_id, :descricao, :destinado, presence: true

  accepts_nested_attributes_for :sondagem_basica_desenvolvimento_atividade_links, :allow_destroy => true

  has_one_attached :atividade_01
  has_one_attached :atividade_02
  has_one_attached :atividade_03
  has_one_attached :atividade_04

  enum destinado: {
    destinado_professor: 1,
    destinado_pais: 2,
    destinado_ambos: 3
  }

  enum tipo_link: {
		site: 1,
		video: 2,
    podcast: 3,
    livro: 4,
    filme: 5,
    rede_social: 6
  }

end
