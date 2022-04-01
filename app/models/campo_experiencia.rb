class CampoExperiencia < ApplicationRecord
    has_many :serie_avaliacao_infantis, dependent: :destroy
    has_many :objetivo_aprendizagem_desenvolvimentos, dependent: :destroy
    has_many :turma_avaliacao_resultados, dependent: :destroy
    has_many :campo_experiencia_atividades, dependent: :destroy

    accepts_nested_attributes_for :campo_experiencia_atividades, :allow_destroy => true

    audited on: [:update, :destroy]	

    validates :nome, presence: true
end
