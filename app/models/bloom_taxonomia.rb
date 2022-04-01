class BloomTaxonomia < ApplicationRecord
    has_many :habilidades, dependent: :destroy
    has_many :turma_avaliacao_resultados, dependent: :destroy
    has_many :turma_avaliacao_lista_adaptadas, dependent: :destroy
    has_many :habilidade_oics, dependent: :destroy
     
    audited on: [:update, :destroy]	
end
