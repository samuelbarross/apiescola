class AvaliacaoConhecimentoQuestao < ApplicationRecord
  belongs_to :avaliacao_conhecimento
  belongs_to :capitulo, optional: true
  belongs_to :capitulo_assunto, optional: true
  belongs_to :habilidade, optional: true
  belongs_to :banco_questao, optional: true
  belongs_to :disciplina, optional: true
  belongs_to :assunto, optional: true
  belongs_to :area_conhecimento, optional: true
  belongs_to :materia, optional: true
  belongs_to :user_anulacao, class_name: "User", foreign_key: :user_anulacao_id, optional: true

  
  has_many :turma_avaliacao_questoes, dependent: :destroy
  has_many :turma_avaliacao_questao_respostas, dependent: :destroy
  has_many :turma_avaliacao_lista_adaptadas, dependent: :destroy
  has_many :avaliacao_conhecimento_questao_links, dependent: :destroy
  has_many :registro_navegacoes, dependent: :destroy
  has_many :ia_plano_acao_oics, dependent: :destroy
  has_many :turma_avaliacao_roteiro_estudos, dependent: :destroy
  has_many :avaliacao_conhecimento_questao_sugestoes, dependent: :destroy

  has_one_attached :imagem_enunciado
  has_one_attached :imagem_enunciado_1
  has_one_attached :imagem_questao_individual
  has_one_attached :imagem_comentario
  has_one_attached :anexo_auxiliar

  audited on: [:update, :destroy]	

  validates :avaliacao_conhecimento_id, :numero, presence: true
  # validates :gabarito, presence: true, if: :avaliacao_aluno?
  # validates :banco_questao_id, presence: true, if: :avaliacao_versao2?
  # validates :habilidade_id, presence: true, if: :questao_lista_oficial?

  accepts_nested_attributes_for :avaliacao_conhecimento_questao_links, :allow_destroy => true

  enum nivel_dificuldade: {
		baixa: 1,
		media: 2,
		alta: 3
  }
  
  enum gabarito: {
    opcao_a: 1,
    opcao_b: 2,
    opcao_c: 3,
    opcao_d: 4,
    opcao_e: 5
  }

  enum abrangencia_lista_adaptada: {
    abrangencia_lista_adaptada_conteudo: 1,
    abrangencia_lista_adaptada_habilidade: 2
  }

  enum item_plano_acao: {
    questao_01: 1,
    questao_02: 2
  }

  def numero_questao_referencia
    if self.questao_referencia_id and self.lista_adaptada?
      AvaliacaoConhecimentoQuestao.find(self.questao_referencia_id).numero
    else 
      nil
    end
  end

  def questao_lista_oficial?
    unless self.lista_adaptada?
      self.errors.add(:habilidade_id, "não pode ficar em branco") if self.habilidade_id.nil? 
      true
    else
      false
    end
  end

  def imagem_enunciado_to_pdf
    return self.imagem_enunciado.variant(resize: "800x600")
  end

  def letra_gabarito
    if self.gabarito
      self.gabarito_i18n
    else
      "Sem Resposta"
    end
  end

  def questoes_lista_adaptada
    AvaliacaoConhecimentoQuestao.where(questao_referencia_id: self.id).where(lista_adaptada: true).pluck(:id)
  end  

  def avaliacao_aluno?
    (self.avaliacao_conhecimento.modelo.eql?("gestao") and !self.avaliacao_conhecimento.modelo.eql?('avaliacao_inteligente')) ? false : true
  end

  def avaliacao_versao2?
    self.avaliacao_conhecimento.versao.eql?("versao_2") ? true : false
  end

  def questao_propria?
    (self.avaliacao_conhecimento_questao_sugestoes.where(questao_propria: true).where(selecao: true).count > 0)
  end

  def nivel_dificuldade_item
    _ndi = ''
    if self.banco_questao_id
      if self.banco_questao.banco_questao_series.where(serie_id: self.avaliacao_conhecimento.serie_id).count > 0
        case self.banco_questao.banco_questao_series.where(serie_id: self.avaliacao_conhecimento.serie_id).first.nivel_dificuldade
        when 'baixa'
          _ndi = 'baixo'
        when 'media'
          _ndi = 'medio'
        when 'alta'
          _ndi = 'alto'
        end
      end
    end

    return _ndi
  end  

end
