class Duvida < ApplicationRecord
  belongs_to :objeto_conhecimento, optional: true
  belongs_to :materia, optional: true
  belongs_to :serie, optional: true
  belongs_to :user_aluno, class_name: 'User', foreign_key: :aluno_user_id, optional: true
  belongs_to :user_professor, class_name: 'User', foreign_key: :professor_user_id, optional: true

  has_many :duvida_mensagens, dependent: :destroy
  has_many :pacote_servico_itens

  audited on: [:update, :destroy]

  validates :descricao, presence: true

  has_one_attached :anexo_arquivo
  has_one_attached :anexo_foto

  enum origem: { 
    tira_duvida: 1,
    tutor_aula: 2,
    suporte: 3
   }

   enum status: {
     aguardando_resposta: 1,
     respondida: 2,
     solucionada: 3
   }
   
end
