class AssuntoQuestao < ApplicationRecord
  belongs_to :assunto
  belongs_to :assunto_serie
  has_many :turma_aluno_assunto_questoes, dependent: :destroy

  audited on: [:update, :destroy]

  validates :tipo_questao, :numero_questao, presence: true

  has_one_attached :imagem_enunciado
  
  enum tipo_questao: {
    tipo_questao_teste_sala: 1,                     # 1o / 2o / 3o médio
    tipo_questao_teste_aprendizagem: 2,             # 1o / 2o / 3o médio
    tipo_questao_teste_aprofundamento: 3,           # 1o / 2o / 3o médio
    tipo_questao_vestibular_regional: 4,            # 3o médio
    tipo_questao_enem: 5,                           # 3o médio
    tipo_questao_vamos_interpretar: 6,              # fundamental I
    tipo_questao_hora_de_praticiar: 7,              # fundamental I e II
    tipo_questao_praticando_em_casa: 8,             # fundamental II
    tipo_questao_indo_mais_fundo: 9,                # fundamental II
    tipo_questao_desenvolvendo_habilidades: 10      # fundamental II
  }

  enum nivel_dificuldade: {
		nivel_dificuldade_facil: 1,
		nivel_dificuldade_medio: 2,
    nivel_dificuldade_dificil: 3,
    nivel_dificuldade_vida: 4
  }

  enum gabarito: {
    opcao_a: 1,
    opcao_b: 2,
    opcao_c: 3,
    opcao_d: 4,
    opcao_e: 5,
    resposta_aberta: 6
  }

end
