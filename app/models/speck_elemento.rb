class SpeckElemento < ApplicationRecord
  has_many :categoria_socio_emocionais

  audited on: [:update, :destroy]

  enum speck_nivel: {
    speck_nivel_big_5: 1,
    speck_nivel_necessidades: 2,
    speck_nivel_valores: 3,
    speck_nivel_bncc_area: 4,
    speck_nivel_bncc_competencia: 5,
    speck_nivel_tipologia2: 6
  }

  enum speck_caracteristica: {
    speck_caracteristica_abertura: 1,
    speck_caracteristica_conscienciosidade: 2,
    speck_caracteristica_extroversao: 3,
    speck_caracteristica_amabilidade: 4,
    speck_caracteristica_faixa_emocional: 5
  }  
end
