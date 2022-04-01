class ConvitePessoa < ApplicationRecord
  belongs_to :turma, optional: true
  belongs_to :pessoa, optional: true
  belongs_to :user
  belongs_to :pessoa_escola, class_name: "Pessoa", foreign_key: :pessoa_escola_id, optional: true
  belongs_to :user_confirmacao, class_name: "User", foreign_key: :user_confirmacao_id, optional: true
  belongs_to :curso, optional: true

  audited on: [:update, :destroy]

  validates :pessoa_escola_id, :perfil, :sexo, presence: :true
  validates :nome, :avatar, presence: true, if: :editado_pelo_convidado? 
  validates :curso_id, :lingua_estrangeira, presence: true, if: :terceira_serie_ensino_medio?
  validates :turma_id, presence: true, if: :perfil_aluno?

  has_one_attached :avatar

	enum perfil: {
		aluno: 1,
		professor: 2,
		gestao_escola: 3,
		diretor: 4,
		coordenador: 5,
		supervisor: 6
  }

	enum sexo: {
		masculino: 1,
		feminino: 2,
    sexo_ignorado: 3
	}  

  enum lingua_estrangeira: {
		convite_pessoa_ingles: 1,
		convite_pessoa_espanhol: 2
	}

  def terceira_serie_ensino_medio?
    if self.turma
      ["3S", "PV", "PVI"].include?(self.turma.serie.codigo) and self.nome
    else
      false
    end
  end

  def editado_pelo_convidado? 
    self.id
  end

  def perfil_aluno?
    self.perfil.eql?("aluno")
  end

  def link_edicao
    # case Rails.env.to_s
    # when "development"
    #   "http://localhost:3000/convite_pessoas/#{self.id}/edit"
    # when
    #   "http://www.vidaeducacao.com.br/convite_pessoas/#{self.id}/edit"
    # end

    "https://www.vidaeducacao.com.br/admin/convite_pessoas/#{self.id}/edit"
  end

end
