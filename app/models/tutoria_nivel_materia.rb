class TutoriaNivelMateria < ApplicationRecord
  belongs_to :pessoa
  belongs_to :nivel
  belongs_to :materia
  belongs_to :user

  audited on: [:update, :destroy]	
end
