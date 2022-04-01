class DuvidaMensagem < ApplicationRecord
  belongs_to :duvida
  belongs_to :user

  has_many :pacote_servico_itens

  after_create :registrar_pacote_servico

  audited on: [:update, :destroy]

  validates :descricao, presence: true

  has_one_attached :anexo_arquivo
  has_one_attached :anexo_foto

  enum status: {
    aguardando_resposta: 1,
    respondida: 2,
    solucionada: 3
  }

  enum tipo_registro: {
    mensagem_abertura: 1,
    comentario: 2,
    resposta: 3,
    substituicao_professor: 4,
    finalizar_solucionada: 5
  }

  def registrar_pacote_servico
    if self.tipo_registro.eql?('resposta')
      if self.duvida.pacote_servico_itens.joins(:pacote_servico).where(pacote_servicos: {user_id: self.user_id}).count.eql?(0)
        pacote_servico = self.user.pacote_servicos.where(data_fechamento: nil).first

        if pacote_servico.nil?
          pacote_servico = PacoteServico.create!(
            user_id: self.user_id,
            data_abertura: Time.zone.now,
            servico: :tira_duvida
          )
        end        

        PacoteServicoItem.create!(
          pacote_servico_id: pacote_servico.id,
          duvida_id: self.duvida_id
        )

        pacote_servico_preco = PacoteServicoPreco.where(servico: :tira_duvida).where(data_vigencia: PacoteServicoPreco.where(servico: :tira_duvida).where('data_vigencia <= ?', Date.today).maximum(:data_vigencia)).first
        if pacote_servico.pacote_servico_itens.count.eql?(pacote_servico_preco.present? ? pacote_servico_preco.qtde_itens : 20)
          if pacote_servico_preco.present?
            pacote_servico.update_columns(valor: pacote_servico_preco.valor, data_fechamento: Time.zone.now)
          end
        end
      end
    end
  end

end
