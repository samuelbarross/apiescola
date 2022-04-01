class PessoaResponsavel < ApplicationRecord
  belongs_to :pessoa
  belongs_to :ano_letivo
  belongs_to :pessoa_pessoa_responsavel, class_name: "Pessoa", foreign_key: "pessoa_responsavel_id"

  validates :pessoa_id, :ano_letivo_id, :pessoa_responsavel_id, :grau_parentesco, presence: :true

  enum grau_parentesco: {
    grau_parentesco_pais: 1,
    grau_parentesco_irmaos: 2,
    grau_parentesco_tios: 3,
    grau_parentesco_avos: 4,
    grau_parentesco_padrastos: 5,
    grau_parentesco_amigos: 6
  }
end
