class ObjetoConhecimento < ApplicationRecord

  has_many :objeto_conhecimento_habilidades, dependent: :destroy
  has_many :objeto_conhecimento_conteudo_digitais, dependent: :destroy
  has_many :objeto_conhecimento_materias, dependent: :destroy
  has_many :ciclo_avaliacao_planejamentos, dependent: :destroy
  has_many :ia_plano_acao_oics, dependent: :destroy
  has_many :duvidas

  audited on: [:update, :destroy]

  validates :descricao, :nivel, presence: true

  accepts_nested_attributes_for :objeto_conhecimento_habilidades, :allow_destroy => true
  accepts_nested_attributes_for :objeto_conhecimento_conteudo_digitais, :allow_destroy => true
  accepts_nested_attributes_for :objeto_conhecimento_materias, :allow_destroy => true

  enum nivel: {
    nivel_pouco_importante: 1,
    nivel_importante: 2,
    nivel_muito_importante: 3
  }

end
