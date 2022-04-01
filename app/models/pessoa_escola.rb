class PessoaEscola < ApplicationRecord
  belongs_to :ano_letivo
  belongs_to :pessoa_pessoa_escola, class_name: "Pessoa", foreign_key:"pessoa_escola_id", optional: true
  belongs_to :pessoa
  belongs_to :pessoa_responsavel_financeiro, class_name: "Pessoa", foreign_key: "pessoa_responsavel_financeiro_id", optional: true

  audited on: [:update, :destroy]	

  validates :pessoa_escola_id, :pessoa_id, :ano_letivo_id, presence: true
end