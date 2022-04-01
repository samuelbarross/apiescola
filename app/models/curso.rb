class Curso < ApplicationRecord
    include Friendlyable

    has_many :curso_nota_cortes, dependent: :destroy
    has_many :turma_alunos, dependent: :destroy
    has_many :area_conhecimento_cursos, dependent: :destroy
    has_many :turma_avaliacao_alunos, dependent: :destroy

    audited on: [:update, :destroy]

    validates :nome, presence: true

    accepts_nested_attributes_for :curso_nota_cortes, :allow_destroy => true

    enum categoria: {
        categoria_1: 1,
        categoria_2: 2,
        categoria_3: 3
    }
end
