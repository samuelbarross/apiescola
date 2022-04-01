class BancoQuestaoMateria < ApplicationRecord
  belongs_to :banco_questao
  belongs_to :materia

	audited on: [:update, :destroy]  

  validate :validar_materia_associada_ao_oic?


  def validar_materia_associada_ao_oic?
    _retorno = true
    if ObjetoConhecimentoMateria.where(objeto_conhecimento_id: self.banco_questao.objeto_conhecimento_habilidade.objeto_conhecimento_id).where(materia_id: self.materia_id).first.nil?
      _retorno = false
      errors.add(:materia_id, ' não está associada ao OIC selecionado na questão.')
    end
    return _retorno
  end

end