class Capitulo < ApplicationRecord
 	belongs_to :disciplina
	belongs_to :livro
	 
	has_many :capitulo_assuntos, dependent: :destroy
	has_many :avaliacao_conhecimento_questoes, dependent: :destroy
	has_many :capitulo_videos, dependent: :destroy
	has_many :capitulo_objeto_conhecimento_habilidades, dependent: :destroy
	
	audited on: [:update, :destroy]

	accepts_nested_attributes_for :capitulo_assuntos, :allow_destroy => true
	accepts_nested_attributes_for :capitulo_videos, :allow_destroy => true
	accepts_nested_attributes_for :capitulo_objeto_conhecimento_habilidades, :allow_destroy => true

	validates :disciplina_id, presence: true

	has_one_attached :pdf_capitulo
end
