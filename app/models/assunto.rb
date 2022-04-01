class Assunto < ApplicationRecord
  belongs_to :disciplina

  has_many :avaliacao_conhecimento_questoes, dependent: :destroy
  has_many :turma_avaliacao_resultados, dependent: :destroy
  has_many :turma_avaliacao_lista_adaptadas, dependent: :destroy
  has_many :capitulo_assuntos, dependent: :destroy
  has_many :assunto_sistema_ensinos, dependent: :destroy
  has_many :assunto_links, dependent: :destroy
  has_many :assunto_edicoes, dependent: :destroy
  has_many :planejamento_pedagogicos, dependent: :destroy
  has_many :assunto_questoes, dependent: :destroy
  has_many :assunto_series, dependent: :destroy
  has_many :turma_aluno_assuntos, dependent: :destroy
  has_many :plano_pedagogico_assuntos, dependent: :destroy

  validates :disciplina_id, presence: true

  accepts_nested_attributes_for :capitulo_assuntos, :allow_destroy => true
  accepts_nested_attributes_for :assunto_sistema_ensinos, :allow_destroy => true
  accepts_nested_attributes_for :assunto_links, :allow_destroy => true
  accepts_nested_attributes_for :assunto_edicoes, :allow_destroy => true

  audited on: [:update, :destroy]
end
