class Sede < ApplicationRecord
  belongs_to :pessoa
  has_many :turmas, dependent: :destroy

  audited on: [:update, :destroy]	

end