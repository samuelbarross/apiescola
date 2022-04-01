class BancoQuestaoSerie < ApplicationRecord
  belongs_to :banco_questao
  belongs_to :serie

  audited on: [:update, :destroy]

  validates :nivel_dificuldade, presence: true

  after_save :start_params

	enum nivel_dificuldade: {
		baixa: 1,
		media: 2,
		alta: 3
  }

  def start_params
    r = Random.new

    # self.banco_questao.parametro_tri_a = r.rand(1...3)
    self.banco_questao.parametro_tri_a = 1.8 - 1.8*Math.sqrt(1-(r.rand(0...1.0)))

    case self.nivel_dificuldade
    when 'baixa'
      self.banco_questao.parametro_tri_b = r.rand(-3...3)
    when 'media'
      self.banco_questao.parametro_tri_b = r.rand(-1...1)
    when 'alta'
      self.banco_questao.parametro_tri_b = r.rand(1...3)
    else
      self.banco_questao.parametro_tri_b = r.rand(-3...3)
    end

    # self.banco_questao.well_defined = nil
    self.banco_questao.parametro_tri_c = self.banco_questao.parametro_tri_c.nil? ? 0.2 : self.banco_questao.parametro_tri_c
    self.banco_questao.save
  end
end
