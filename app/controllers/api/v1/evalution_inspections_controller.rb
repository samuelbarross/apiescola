class Api::V1::EvalutionInspectionsController < Api::V1::ApiController
  before_action :authenticate_user, only: %i[create]
  wrap_parameters false
  
  def create
    _status, _msg, _arr = validate_json(evalution_params)

    if _status.eql? :error
      render json: { error: "#{_msg}#{_arr}" }, status: 500
      return
    end

    #### Only validade body json in swagger
    if evalution_params[:in_swagger].nil? or evalution_params[:in_swagger].eql? true
      render json: {success: 'Dados válidos'}, status: 200
      return
    end

    _taf = TurmaAvaliacaoFiscalizacao.create!(
      turma_avaliacao_id: evalution_params[:turma_avaliacao_id],
      turma_aluno_id: evalution_params[:turma_aluno_id],
      tipo_registro: set_type_register(evalution_params[:tipo_registro])
    )

    render json: { success: "#{evalution_params[:tipo_registro]} registrada!" }, status: 200
  end

  private
  def evalution_params
    params.permit(:turma_avaliacao_id, :turma_aluno_id, :tipo_registro, :in_swagger)
  end

  def set_type_register(_registro)
    unless _registro.nil?
      return _registro.titlecase.eql?('Saida') ? 1 : _registro.titlecase.eql?('Entrada') ? 2 : nil
    end
  end

  def validate_json(_params)
    _arr  = ['turma_avaliacao_id', 'turma_aluno_id', 'tipo_registro', 'in_swagger']
 
    ### Validates Tags
    return :error, 'requer tag: ', _arr - _params.keys unless (_arr- _params.keys).blank?

    ### Validates Values
    _arr_blanks = []

    if _params[:turma_avaliacao_id].blank? ||
      _params[:turma_aluno_id].blank? ||
      _params[:turma_aluno_id].blank? ||
      _params[:turma_aluno_id].blank?

      _arr_blanks.push('turma_avaliacao_id') if _params[:sede].blank?
      _arr_blanks.push('turma_aluno_id') if _params[:nome_estado].blank?
      _arr_blanks.push('turma_aluno_id') if _params[:municipio][:nome].blank?
      _arr_blanks.push('turma_aluno_id') if _params[:municipio][:codigo_ibge].blank?

      return :error, 'Não é permitido valores em branco para: ', _arr_blanks
    end
  end
end
