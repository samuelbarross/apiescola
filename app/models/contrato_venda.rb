class ContratoVenda < ApplicationRecord
	belongs_to :pessoa_escola, class_name: "Pessoa", foreign_key: :pessoa_escola_id
	belongs_to :pessoa_vendedor, class_name: "Pessoa", foreign_key: :pessoa_vendedor_id
	has_many :contrato_venda_ano_letivos, dependent: :destroy
	audited on: [:update, :destroy]	
	after_create :incluir_ano_letivo

	enum status: {
		ativo: 1,
		inativo: 2
	}

	enum periodicidade: {
		tres_anos: 1,
		quatro_anos: 2,
		cinco_anos: 3,
		um_ano: 4
	}

	enum tipo_operacao: {
		tipo_operacao_venda: 1,
		tipo_operacao_prospeccao: 2
	}

	validates :pessoa_escola_id, :pessoa_vendedor_id, :data_emissao, :ano_letivo_inicial, :periodicidade, :tipo_operacao, presence: true
#	validate :validar_ano_letivo

  # def validar_ano_letivo
	# 	self.errors.add(:ano_letivo_inicial, "Ano letivo inicial não pode ser menor ou igual ao ano atual") if self.ano_letivo_inicial < Date.today.year
	# end
	
	def incluir_ano_letivo
		case self.periodicidade
			when 'tres_anos'
				qtLoop = 2
			when 'quatro_anos'
				qtLoop = 3
			when 'cinco_anos'
				qtLoop = 4
			else 
				qtLoop = 0
		end
		passo = 0
		while passo <= qtLoop do 		
			ano_letivo_referencia = self.ano_letivo_inicial + passo
			ano_letivo = AnoLetivo.find_by_ano(ano_letivo_referencia)

			if self.pessoa_escola.pessoa_escolas.where('pessoa_escolas.pessoa_escola_id = ?', self.pessoa_escola_id).where('pessoa_escolas.ano_letivo_id = ?', ano_letivo.id).first.nil?
				PessoaEscola.create!(
					pessoa_escola_id: self.pessoa_escola_id,
					pessoa_id: self.pessoa_escola_id,
					ano_letivo_id: ano_letivo.id,
					created_at: Time.now,
					updated_at: Time.now
				)
			end

			contrato_venda_ano_letivo = ContratoVendaAnoLetivo.where(contrato_venda_id: self.id).where(ano_letivo_id: ano_letivo.id).first
			if contrato_venda_ano_letivo.nil?
				contrato_venda_ano_letivo = ContratoVendaAnoLetivo.create!(
					contrato_venda_id: self.id,
					ano_letivo_id: ano_letivo.id,
					created_at: Time.now,
					updated_at: Time.now
				)
			end
			for _numero_etapa in 1..5
				if ContratoVendaAnoLetivoEtapa.where(contrato_venda_ano_letivo_id: contrato_venda_ano_letivo.id).where(numero: _numero_etapa).first.nil?
					ContratoVendaAnoLetivoEtapa.create!(
						contrato_venda_ano_letivo_id: contrato_venda_ano_letivo.id,
						tipo: _numero_etapa < 5 ? 1 : 2,
						nome: _numero_etapa < 5 ? _numero_etapa.to_s + 'a Etapa ' : 'Recuperação',
						data_inicio: nil,
						data_fim: nil,
						peso: 1,
						numero: _numero_etapa,
						created_at: Time.now,
						updated_at: Time.now
					)
				end
			end
			passo += 1
		end		
		true
	end

  def turmas
		ContratoVenda.select("ano_letivos.ano, series.nome as serie_nome, turmas.codigo, (case turmas.turno when 1 then 'Manhã' when 2 then 'Tarde' when 3 then 'Noite' when 4 then 'Integral' else '' end) as turno, niveis.nome as nivel_nome, turmas.id as turma_id")
					 .joins('inner join contrato_venda_ano_letivos on (contrato_vendas.id = contrato_venda_ano_letivos.contrato_venda_id)')
					 .joins('inner join contrato_venda_ano_letivo_series on (contrato_venda_ano_letivos.id = contrato_venda_ano_letivo_series.contrato_venda_ano_letivo_id) ')
					 .joins('inner join series on (contrato_venda_ano_letivo_series.serie_id = series.id)')
					 .joins('inner join niveis on (series.nivel_id = niveis.id)')
					 .joins('inner join ano_letivos on (contrato_venda_ano_letivos.ano_letivo_id = ano_letivos.id)')
					 .where('contrato_vendas.id = ?', self.id)
	end
  
end
