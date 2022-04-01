class GrupoEntidade < ApplicationRecord
	has_many :pessoa_grupo_entidades, dependent: :destroy
    audited on: [:update, :destroy]	
end
