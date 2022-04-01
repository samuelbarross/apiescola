class PlanejamentoPedagogico < ApplicationRecord
  belongs_to :serie_disciplina, optional: true
  belongs_to :assunto, optional: true
  belongs_to :serie, optional: true
  belongs_to :disciplina, optional: true
  belongs_to :ano_letivo, optional: true

  has_many :planejamento_pedagogico_assuntos

  audited on: [:update, :destroy] 

  validates :serie_id, :ano_letivo_id, :disciplina_id, :numero_unidade, presence: true

  accepts_nested_attributes_for :planejamento_pedagogico_assuntos, :allow_destroy => true

	enum tipo_material: {
		tipo_material_7v: 1,
		tipo_material_14v: 2,
    tipo_material_instensivo: 3,
    tipo_material_todos: 4
  }
    
end
