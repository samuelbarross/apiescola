class CicloAvaliacaoEscola < ApplicationRecord
  belongs_to :ciclo_avaliacao
  belongs_to :pessoa
  belongs_to :user, optional: true

  has_many :ciclo_avaliacao_escola_agendamentos, dependent: :destroy

  audited on: [:update, :destroy]

  def resumo_geracao_avaliacao
    _label_geracao = "label label-danger"
    _qtde_series = self.ciclo_avaliacao_escola_agendamentos.select(:serie_id).distinct.count
    _qtde_turmas = self.ciclo_avaliacao_escola_agendamentos.count
    _qtde_geradas = self.ciclo_avaliacao_escola_agendamentos.where('avaliacao_conhecimento_id is not null').select(:serie_id).distinct.count

    if _qtde_geradas > 0 
      if _qtde_series.eql?(_qtde_geradas)
        _label_geracao = "label label-primary"
      else
        _label_geracao = "label label-warning"
      end
    end
    
    return { qtde_series: _qtde_series, qtde_turmas: _qtde_turmas, qtde_geradas: _qtde_geradas, label_geracao: _label_geracao }
  end

  def resumo_agendamento
    
  end
end
