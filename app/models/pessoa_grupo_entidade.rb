class PessoaGrupoEntidade < ApplicationRecord
	belongs_to :pessoa
	belongs_to :pessoa_escola, class_name: "Pessoa", foreign_key: :pessoa_escola_id, optional: true
	belongs_to :grupo_entidade

	before_create :assumir_pessoa_escola
	after_create :incluir_pessoa_escola
	after_update :incluir_pessoa_escola

  audited on: [:update, :destroy]

	validates :grupo_entidade_id, presence: true
	
	def incluir_pessoa_escola
		ContratoVenda.where(pessoa_escola_id: self.pessoa_escola_id).each do |contrato_venda|
			contrato_venda.contrato_venda_ano_letivos.each do |contrato_venda_ano_letivo|
				if PessoaEscola.where(pessoa_id: self.pessoa_id).where(pessoa_escola_id: self.pessoa_escola_id).where(ano_letivo_id: contrato_venda_ano_letivo.ano_letivo_id).count == 0 
					PessoaEscola.create!(
						pessoa_id: self.pessoa_id,
						pessoa_escola_id: self.pessoa_escola_id,
						ano_letivo_id: contrato_venda_ano_letivo.ano_letivo_id,
						matricula: self.pessoa.matricula_escola,
						created_at: Time.now,
						updated_at: Time.now
					)
				end
			end
		end
	end

	def assumir_pessoa_escola
		if self.pessoa_escola_id.nil?			
			if self.grupo_entidade.sigla == 'ESC'
				self.pessoa_escola_id = self.pessoa_id
			end
		end
		true
	end
end
