class Api::V1::ManagersController < Api::V1::ApiController
  before_action :authenticate_user, only: %i[create]
  wrap_parameters false

  def create
    begin
      unless migration_params.blank?
        _ano_letivo         = @current_user.ano_letivo
        _status, _msg, _arr = validate_json(migration_params, _ano_letivo)

        if _status.eql? :error
          render json: { error: "#{_msg}#{_arr}" }, status: 500
          return
        end

        #### Only validade body json in swagger
        if migration_params[:in_swagger].nil? or migration_params[:in_swagger].blank? or migration_params[:in_swagger].eql? true
          render json: {success: 'Dados válidos'}, status: 200
          return
        end

        _estado = Estado.find_by_nome(migration_params[:nome_estado].upcase)
        _cidade = Cidade.where(nome: migration_params[:municipio][:nome].upcase)
        _cidade = _cidade.where(codigo_ibge: migration_params[:municipio][:codigo_ibge]) if migration_params[:municipio][:codigo_ibge].present?
        _cidade = _cidade.first

        _cidade = Cidade.create!(
          estado_id:   _estado.id,
          nome:        migration_params[:municipio][:nome].upcase,
          codigo_ibge: migration_params[:municipio][:codigo_ibge]
        ) if _cidade.nil?

        _pessoa_escola = PessoaEscola.find(@current_user.pessoa_escola_id)
        _sede          = Sede.find_by_pessoa_id(_pessoa_escola.pessoa_escola_id)

        _sede = Sede.create!(
          pessoa_id:     _pessoa_escola.pessoa_escola_id,
          nome:          migration_params[:sede].upcase,
          estado_id:     _estado.id,
          cidade_id:     _cidade.id,
          nome_distrito: migration_params[:municipio][:nome_distrito]
        ) if _sede.nil?

        migration_params[:pessoas].each do |pessoa|
          _pessoa = Pessoa.where(nome: pessoa[:nome])
          _pessoa = _pessoa.where(matricula_escola: pessoa[:matricula]) if pessoa[:matricula].present?
          _pessoa = _pessoa.where(email: pessoa[:email]) if pessoa[:email].present?
          _pessoa = _pessoa.first

          if _pessoa.nil?
            _pessoa = Pessoa.create!(
              nome:             pessoa[:nome],
              tipo_pessoa:      1,
              email:            pessoa[:email],
              cpf:              set_cpf(pessoa[:cpf]),
              sexo:             set_sexo(pessoa[:sexo]),
              nome_fantasia:    pessoa[:nome].split()[0], ### FIRST NAME
              matricula_escola: set_matricula(pessoa[:matricula]),
              data_nascimento:  pessoa[:data_nascimento]
            )
          end

          _grupo_entidade_id = set_categoria(pessoa[:categoria])

          if _pessoa.pessoa_grupo_entidades.where(grupo_entidade_id: _grupo_entidade_id).where(pessoa_escola_id: _sede.pessoa_id).first.nil?
            PessoaGrupoEntidade.create!(
              pessoa_id:          _pessoa.id,
              pessoa_escola_id:   _sede.pessoa_id,
              grupo_entidade_id:  _grupo_entidade_id
            )

            _pessoa.criar_usuario
          end

          if _pessoa.pessoa_escolas.where(pessoa_escola_id: _sede.pessoa_id).where(ano_letivo_id: _ano_letivo.id).first.nil?
            PessoaEscola.create!(
              pessoa_escola_id: _sede.pessoa_id,
              pessoa_id:        _pessoa.id,
              ano_letivo_id:    _ano_letivo.id,
              matricula:        _pessoa.matricula_escola
            )

            _pessoa.criar_usuario
          end

          case pessoa[:categoria]
          when 'Aluno(a)'
            _turma_id = set_turma(pessoa[:niveis].first, _sede, _ano_letivo)

            if _pessoa.turma_alunos.find_by_turma_id(_turma_id).nil?
              TurmaAluno.create!(
                turma_id:           _turma_id,
                pessoa_aluno_id:    _pessoa.id,
                status:             :ativo,
                lingua_estrangeira: 1
              )
            end
          when 'Professor(a)'
            pessoa[:niveis].each do |nivel|
              _disciplina = Disciplina.find_by_nome(nivel[:disciplina])

              if _disciplina
                _turma_id = set_turma(nivel, _sede, _ano_letivo)

                if _pessoa.pessoa_turma_professores.where(turma_id: _turma_id).where(disciplina_id: _disciplina.id).first.nil?
                  TurmaProfessor.create!(
                    turma_id:            _turma_id,
                    pessoa_professor_id: _pessoa.id,
                    disciplina_id:      _disciplina.id,
                    status:             :ativo
                  )
                end
              end
            end

          when 'Coordernador(a)', 'Coordenador Pedagógico', 'Coordenador de Área'
            pessoa[:niveis].each do |nivel|
              _serie_id = set_serie(nivel[:serie], nivel[:nivel])

              if _pessoa.serie_coordenacoes.where(pessoa_id: _pessoa.id).where(pessoa_escola_id: _sede.pessoa_id).where(serie_id: _serie_id).first.nil?
                SerieCoordenacao.create!(
                  pessoa_id:         pessoa.id,
                  pessoa_escola_id: _sede.pessoa_id,
                  serie_id:         _serie_id,
                  ativo:            true
                )
              end
            end
          end
        end

        render json: { success: 'Migração concluída com sucesso!' }, status: 200
      else
        render json: { error: 'Sem dados para migração!' }, status: 500
      end
    rescue Exception => e
      render json: { errors: e.message }, status: 500
    end
  end

  private
  def migration_params
    params.permit(:in_swagger, :sede, :nome_estado,
      municipio: [:nome, :codigo_ibge, :nome_distrito],
      pessoas: [:nome, :cpf, :sexo, :email, :data_nascimento, :matricula, :categoria,
        niveis: [:nivel, :serie, :turma, :turno, :disciplina]
      ]
    )
  end

  def set_cpf(_cpf)
    unless _cpf.nil?
      return _cpf.scan(/\d/).join('').length == 11 ?  _cpf.scan(/\d/).join('') : nil
    end
  end

  def set_sexo(_sexo)
    unless _sexo.nil?
      return _sexo.titlecase.eql?('Masculino') ? 1 : _sexo.titlecase.eql?('Feminino') ? 2 : nil
    end
  end

  def set_matricula(_matricula)
    unless _matricula.nil?
      if _matricula.blank?
        begin
          _matricula = rand(Time.now.to_i).to_s[0..9]
        end until Pessoa.find_by_matricula_escola(_matricula).nil?
      end

      return _matricula
    end
  end

  def set_categoria(_categoria)
    case _categoria
    when 'Aluno(a)'
      grupo_entidade = GrupoEntidade.find_by_sigla('ALU')
    when 'Profressor(a)'
      grupo_entidade = GrupoEntidade.find_by_sigla('PRO')
    when 'Diretor(a)', 'Diretor Pedagógico'
      grupo_entidade = GrupoEntidade.find_by_sigla('DIR')
    when 'Coordernador(a)', 'Coordenador Pedagógico', 'Coordenador de Área'
      grupo_entidade = GrupoEntidade.find_by_sigla('COR')
    when 'Administrativo'
      grupo_entidade = GrupoEntidade.find_by_sigla('FUN')
    when 'Supervisor(a)', 'Mantenedor', 'Supervisor Pedagógico'
      grupo_entidade = GrupoEntidade.find_by_sigla('SUP')
    when 'Pais/Responsáveis'
      grupo_entidade = GrupoEntidade.find_by_sigla('PAR')
    when 'Psicólogos'
      grupo_entidade = GrupoEntidade.find_by_sigla('PSI')
    else
      grupo_entidade = nil
    end

    return grupo_entidade.id
  end

  def set_nivel(_nivel)
    case _nivel
    when 'Ensino_Fundamental_1'
      _nivel = Nivel.find_by_codigo('EF1')
    when 'Ensino_Fundamental_2'
      _nivel = Nivel.find_by_codigo('EF2')
    when 'Ensino_Infantil'
      _nivel = Nivel.find_by_codigo('EI')
    when 'Ensino_Médio'
      _nivel = Nivel.find_by_codigo('EM')
    when 'Pré_Vestibular'
      _nivel = Nivel.find_by_codigo('PV')
    else
      _nivel = nil
    end

    return _nivel.id
  end

  def set_serie(_serie, _nivel)
    _nivel_id = set_nivel(_nivel)

    case _serie
    when 'INFANTIL I'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: 'INF I').first
    when 'INFANTIL II'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: 'INF II').first
    when 'INFANTIL III'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: 'INF III').first
    when 'INFANTIL IV'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: 'INF IV').first
    when 'INFANTIL V'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: 'INF V').first
    when '1º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '1A').first
    when '2º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '2A').first
    when '3º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '3A').first
    when '4º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '4A').first
    when '5º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '5A').first
    when '6º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '6A').first
    when '7º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '7A').first
    when '8º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '8A').first
    when '9º ano'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '9A').first
    when  '1ª série'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '1S').first
    when '2ª série'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '2S').first
    when '3° série', '3ª série'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: '3S').first
    when 'Pré Universitário'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: 'PV').first
    when 'Pré Universitário Intensivo'
      _serie = Serie.where(nivel_id: _nivel_id).where(codigo: 'PVI').first
    else
      _serie = nil
    end

    return _serie.id
  end

  def set_turno(_turno)
    case _turno
    when 'Manhã'
      _turno = 1
    when 'Tarde'
      _turno = 2
    when 'Noite'
      _turno = 3
    when 'Integral'
      _turno = 4
    end

    return _turno
  end

  def set_turma(_nivel, _sede, _ano_letivo)
    _serie_id = set_serie(_nivel[:serie], _nivel[:nivel])
    _nivel_id = set_nivel(_nivel[:nivel])
    _turno    = set_turno(_nivel[:turno])

    _turma = Turma.where(pessoa_escola_id: _sede.pessoa_id)
      .where(sede_id: _sede.id)
      .where(ano_letivo_id: _ano_letivo.id)
      .where(nivel_id: _nivel_id)
      .where(serie_id: _serie_id)
      .where(turno: _turno)
    .where(codigo: _nivel[:turma]).first

    if _turma.nil?
      _contrato_venda = set_contrato_venda(_ano_letivo, _nivel)

      _contrato_venda_ano_letivo = _contrato_venda.contrato_venda_ano_letivos
        .joins('inner join contrato_venda_ano_letivo_series as cvals on (contrato_venda_ano_letivos.id = cvals.contrato_venda_ano_letivo_id)')
        .where(ano_letivo_id: _ano_letivo.id)
      .where('cvals.serie_id = ?', _serie_id).first

      _contrato_venda_ano_letivo_serie = contrato_venda_ano_letivo.contrato_venda_ano_letivo_series
        .where(serie_id: _serie_id)
      .first

      _turma = Turma.create!(
        contrato_venda_ano_letivo_serie_id: _contrato_venda_ano_letivo_serie.id,
        codigo:                             _nivel[:turma],
        turno:                              _turno,
        pessoa_escola_id:                   _sede.pessoa_id,
        ano_letivo_id:                      _ano_letivo_id.id,
        serie_id:                           _serie_id,
        nivel_id:                           _nivel_id,
        sede_id:                            _sede.id,
        sistema_ensino_id:                  SistemaEnsino.find_by_nome_curto('SVIDA')
      )

      return _turma.id
    else
      return _turma.id
    end
  end

  def validate_json(_params, _ano_letivo)
    _arr_sede      = ['sede', 'nome_estado', 'municipio', 'pessoas', 'in_swagger']
    _arr_municipio = ['nome', 'codigo_ibge']

    ### Validates Tags
    return :error, 'requer tag: ', _arr_sede - _params.keys unless (_arr_sede - _params.keys).blank?
    return :error, 'requer tag: ',  _arr_municipio - _params.keys unless (_arr_municipio - _params[:municipio].keys).blank?

    ### Validates Values
    _arr_blanks = []

    if _params[:sede].blank? ||
      _params[:nome_estado].blank? ||
      _params[:municipio][:nome].blank? ||
      _params[:municipio][:codigo_ibge].blank?

      _arr_blanks.push('sede') if _params[:sede].blank?
      _arr_blanks.push('nome_estado') if _params[:nome_estado].blank?
      _arr_blanks.push('municipio_nome') if _params[:municipio][:nome].blank?
      _arr_blanks.push('municipio_codigo_ibge') if _params[:municipio][:codigo_ibge].blank?

      return :error, 'Não é permitido valores em branco para: ', _arr_blanks
    end

    _arr_pessoa             = ['nome', 'categoria']
    _arr_categorias         = ['Aluno(a)', 'Professor(a)', 'Diretor(a)', 'Diretor Pedagógico', 'Coordernador(a)', 'Coordenador Pedagógico', 'Coordenador de Área', 'Administrativo', 'Supervisor(a)', 'Mantenedor', 'Supervisor Pedagógico', 'Pais/Responsáveis', 'Psicólogos']
    _arr_exigir_nivel       = ['Aluno(a)', 'Professor(a)', 'Coordernador(a)', 'Coordenador Pedagógico', 'Coordenador de Área']

    _params[:pessoas].each do |pessoa|
      return :error, 'Pessoa requer: ', _arr_pessoa - pessoa.keys unless (_arr_pessoa - pessoa.keys).blank?
      return :error, 'Não é permitido valor em branco para: ', ['pessoa_nome'] if pessoa[:nome].blank?
      return :error, "#{pessoa[:categoria]} inexistente, valores válidos: ", _arr_categorias unless _arr_categorias.include? pessoa[:categoria]

      if pessoa[:categoria].eql? 'Aluno(a)'
        _arr = (_arr_pessoa << ['matricula', 'niveis']).flatten!

        return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} requer: ", _arr - pessoa.keys unless (_arr - pessoa.keys).blank?
      elsif pessoa[:categoria].eql?('Coordernador(a)') ||
        pessoa[:categoria].eql?('Coordenador Pedagógico') ||
        pessoa[:categoria].eql?('Coordenador de Área')

        _arr = (_arr_pessoa << ['niveis']).flatten!

        return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} requer: ", _arr - pessoa.keys unless (_arr - pessoa.keys).blank?
      elsif pessoa[:categoria].eql? 'Professor(a)'
        _arr = (_arr_pessoa << ['niveis']).flatten!

        return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} requer: ", _arr - pessoa.keys unless (_arr - pessoa.keys).blank?
      end

      if _arr_exigir_nivel.include? pessoa[:categoria]
        return :error, "#{pessoa[:categoria]} requer:", ['niveis'] if pessoa[:niveis].count == 0
        return :error, "#{pessoa[:categoria]} contém mais de um nível", ["qtde_informada: #{pessoa[:niveis].count.to_s}"] if pessoa[:niveis].count > 1 and pessoa[:categoria].eql? 'Aluno(a)'

        pessoa[:niveis].each do |nivel|
          if pessoa[:categoria].eql? 'Professor(a)'
            _arr_niveis = ['nivel', 'serie', 'turma', 'turno', 'disciplina']
            return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} requer: ", _arr_niveis - nivel.keys unless (_arr_niveis - nivel.keys).blank?

            if nivel[:nivel].blank? or nivel[:serie].blank? or nivel[:turma].blank? or nivel[:turno].blank? or nivel[:disciplina].blank?

              _arr_blanks.push('nivel') if nivel[:nivel].blank?
              _arr_blanks.push('serie') if nivel[:serie].blank?
              _arr_blanks.push('turma') if nivel[:turma].blank?
              _arr_blanks.push('turno') if nivel[:turno].blank?
              _arr_blanks.push('disciplina') if nivel[:disciplina].blank?

              return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} não é permitido valores em branco para: ", _arr_blanks
            end
          elsif pessoa[:categoria].eql?('Coordernador(a)') ||
            pessoa[:categoria].eql?('Coordenador Pedagógico') ||
            pessoa[:categoria].eql?('Coordenador de Área')

            _arr_niveis = ['nivel', 'serie']
            return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} requer: ", _arr_niveis - nivel.keys unless (_arr_niveis - nivel.keys).blank?

            if nivel[:nivel].blank? or nivel[:serie].blank?
              _arr_blanks.push('nivel') if nivel[:nivel].blank?
              _arr_blanks.push('serie') if nivel[:serie].blank?

              return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} não é permitido valor em branco para: ", _arr_blanks
            end
          elsif pessoa[:categoria].eql? 'Aluno(a)'
            _arr_niveis  = ['nivel', 'serie', 'turma', 'turno']
            return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} requer: ", _arr_niveis - nivel.keys unless (_arr_niveis - nivel.keys).blank?

            if nivel[:nivel].blank? or nivel[:serie].blank? or nivel[:turma].blank? or nivel[:turno].blank?
              _arr_blanks.push('nivel') if nivel[:nivel].blank?
              _arr_blanks.push('serie') if nivel[:serie].blank?
              _arr_blanks.push('turma') if nivel[:turma].blank?
              _arr_blanks.push('turno') if nivel[:turno].blank?

              return :error, "#{pessoa[:categoria]}: #{pessoa[:nome]} não é permitido valores em branco: ", _arr_blanks
            end
          end

          return :error, "#{_params[:sede]}: #{nivel[:nivel]} sem contrato/#{nivel[:serie]} ano letivo: ", _ano_letivo.ano unless set_contrato_venda(_ano_letivo, nivel)
        end
      end
    end
  end

  def set_contrato_venda(_ano_letivo, _nivel)
    _serie_id = set_serie(_nivel[:serie], _nivel[:nivel])

    _contrato_venda = @current_user.pessoa.contrato_venda_escolas
      .joins('inner join contrato_venda_ano_letivos as cval on (contrato_vendas.id = cval.contrato_venda_id)')
      .joins('inner join contrato_venda_ano_letivo_series as cvals on (cval.id = cvals.contrato_venda_ano_letivo_id)')
      .where('cval.ano_letivo_id = ?', _ano_letivo.id)
    .where('cvals.serie_id = ?', _serie_id).first

    return _contrato_venda
  end
end
