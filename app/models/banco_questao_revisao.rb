class BancoQuestaoRevisao < ApplicationRecord
  belongs_to :banco_questao
  belongs_to :user

  after_save :atualizar_status_banco_questao

  audited on: [:update, :destroy]

  validates :comentario, :status, presence: true

  enum status: {
		ativa: 1,
		revisao: 2,
		aprovada: 3,
		inativa: 4
  }
  
  def atualizar_status_banco_questao
    self.banco_questao.update!(status: self.status)
  end

  def classe_span_status
    classe = "label label-danger"

    case self.status
    when 'ativa'
      classe = "label label-danger"
    when 'revisao'
      classe = "label label-warning"
    when 'aprovada'
			classe = "label label-primary"
    when 'inativa'
      classe = "label label-muted"			
    end

    classe
  end	
    
end
