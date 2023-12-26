unit uControleColaborador;

interface

uses
  uRepo,
  uSQLAttr,
  uValidacaoSimples,
  uControleProjeto,
  uUtility,
  System.StrUtils,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FireDac.Comp.Client,
  FireDac.Stan.Error,
  uSQLRTTIBuilders,
  D16Grids;

type

  [TDbTable('controleferias.colaborador')]
  TColaborador = class

    { nome colunas colaborador }
    const clIdColaborador      = 'IdColaborador';
    const clDsColaborador      = 'DsColaborador';
    const clLogin              = 'Login';
    const clObservacao         = 'Observacao';
    const clStAtivo            = 'StAtivo';
    const clDtCadastro         = 'DtCadastro';
    const clTotalDiasPrevistos = 'TotalDiasPrevistos';

    { nome constraints colaborador }
    const constUqNmUsuario = 'uq_colaborador_nmusuario';

    private
      [TDbSeqId]
      [TDbField(clIdColaborador)]
      fId : Integer;

      [TDbField(clDsColaborador)]
      fDescricao : String;

      [TDbField(clLogin)]
      fLogin : String;

      [TDbField(clObservacao)]
      fObservacao : String;

      [TDbField(clStAtivo)]
      fStAtivo : Boolean;

      [TDbField(clDtCadastro)]
      fDataCadastro : TDateTime;

      [TDbField(clTotalDiasPrevistos)]
      fTotalDiasPrevistos : Integer;

    public
      property Id : Integer read fId;
      property Descricao : String read fDescricao write fDescricao;
      property Login : String read fLogin write fLogin;
      property Observacao : String read fObservacao write fObservacao;
      property StAtivo : Boolean read fStAtivo write fStAtivo;
      property DataCadastro : TDateTime read fDataCadastro write fDataCadastro;
      property TotalDiasPrevistos : Integer read fTotalDiasPrevistos write fTotalDiasPrevistos;


  end;

  [TDbTable('controleferias.cbperiodos')]
  TCbPeriodos = class

    { nome colunas cbperiodos }
    const clIdCbPeriodo = 'IdCbPeriodo';
    const clDtInicio = 'DtInicio';
    const clDtFinal = 'DtFinal';

    private
      [TDbSeqId]
      [TDbField(clIdCbPeriodo)]
      fIdCbPeriodo : Integer;

      [TDbField(TColaborador.clIdColaborador)]
      fIdColaborador : Integer;

      [TDbField(clDtInicio)]
      fDataInicio : TDateTime;

      [TDbField(clDtFinal)]
      fDataFinal : TDateTime;

    public
      property IdCbPeriodo : Integer read fIdCbPeriodo;
      property IdColaborador : Integer read fIdColaborador write fIdColaborador;
      property DataInicio : TDateTime read fDataInicio write fDataInicio;
      property DataFinal : TDateTime read fDataFinal write fDataFinal;

  end;

  [TDbTable('controleferias.cbproj')]
  TCbProj = class

    { nome colunas cbproj }
    const clIdCbProj = 'IdCProj';

    { nome constraints cbproj }
    const constUqIdColabProj = 'uq_cbproj_idcolabproj';

    private
      [TDbSeqId]
      [TDbField(clIdCbProj)]
      fIdCbProj : Integer;

      [TDbField(TColaborador.clIdColaborador)]
      fIdColaborador : Integer;

      [TDbField(TProjeto.cfIdProj)]
      fIdProjeto : Integer;

    public
      property IdCbProj : Integer read fIdCbProj;
      property IdProjeto : Integer read fIdProjeto;
      property IdColaborador : Integer read fIdColaborador;

  end;

  [TDbDummy]
  TConflitoFerias = class
    private
      [TDbField('login')]
      fLogin : String;

      [TDbField('validacao')]
      fValidacao : String;

      [TDbField('dtinicio')]
      fDtInicio : TDate;

      [TDbField('dtfinal')]
      fDtFinal : TDate;

  end;

  TFiltroConflitos = (Todos, SemConflito, ComConflitos);

  TDAOColaborador = class(TFdRTDao<TColaborador>) end;
  TDAOCbProj = class(TFdRTDao<TCbProj>) end;
  TDAOCbPeriodos = class(TFdRTDao<TCbPeriodos>) end;

  TGerenciadorColaborador = class(TInterfacedObject, IDbErrorHandler)
    private
      fDaoColaborador : TDAOColaborador;
      fDaoCbProj : TDAOCbProj;
      fDaoCbPeriodos : TDAOCbPeriodos;

      procedure HandleException(exception: EFDDBEngineException);

    protected
      property DaoColaborador : TDAOColaborador read fDaoColaborador;
      property DaoCbPeriodos : TDAOCbPeriodos read fDaoCbPeriodos;
      property DaoCbProj : TDAOCbProj read fDaoCbProj;

    public
      constructor Create(var fdConnection: TFDConnection);

      {CbPeriodos}
      function VerificarAutoColapso(const dtInicio, dtFinal: TDateTime; const idcolaborador: Integer;
                                    out datasEmConflito: TList<String>): Boolean;
      function LocalizarTodosPeriodos(out cbPeriodos: TList<TCbPeriodos>): Boolean;
      function LocalizarPeriodosPorColaborador(const idcolaborador: Integer;
                                               out cbPeriodos: TList<TCbPeriodos>): Boolean;

      procedure LimparTodosPeriodosPorId(const idColaborador: Integer);
      procedure RemoverPeriodoFeriasPorId(const idCbPeriodo, idColaborador: Integer);
      procedure AdicionarPeriodoFeriasPorId(const dtInicio, dtFinal: TDateTime; idColaborador: Integer);
      procedure VerificarConflitosDePeriodo(const dtInicio, dtFinal: TDateTime; var tdcGrid: TDCGrid;
                                           const flConflito: TFiltroConflitos; const idColaborador: Integer);

      {Colaborador}
      function LocalizarPorLogin(const nome: String; out colaborador: TColaborador): Boolean;
      procedure AtualizarColaboradorPorId(const idColaborador: Integer; alteracoes: TDictionary<String, Variant>);
      function LocalizarTodos(out colaboradores: TList<TColaborador>): Boolean;
      procedure ExcluirColaboradorPorId(idcolaborador: Integer);
      function CriarColaborador(colaborador: TColaborador): Boolean;

      {Projeto}
      procedure AdicionarProjeto(idcolaborador: Integer; nomeProjeto: String);

  end;

var
  GerenciadorColaborador : TGerenciadorColaborador;

implementation

constructor TGerenciadorColaborador.Create(var fdConnection: TFDConnection);
begin
  fDaoColaborador := TDAOColaborador.Create(fdConnection);
  fDaoCbPeriodos := TDAOCbPeriodos.Create(fdConnection);
  fDaoCbProj := TDAOCbProj.Create(fdConnection);
  fDaoColaborador.ErrorHandler := Self;
  fDaoCbPeriodos.ErrorHandler := Self;
  fDaoCbProj.ErrorHandler := Self;
end;

procedure TGerenciadorColaborador.AdicionarProjeto(idcolaborador: Integer; nomeProjeto: String);
var
  CbProj : TCbProj;
  Proj : TProjeto;
begin
  if GerenciadorProjeto.LocalizarPorNome(nomeProjeto, Proj) then
  begin
    CbProj := TCbProj.Create;
    CbProj.fIdColaborador := idcolaborador;
    CbProj.fIdProjeto := Proj.IdProjeto;
    DaoCbProj.Insert(CbProj);
  end;

end;

function TGerenciadorColaborador.VerificarAutoColapso(const dtInicio, dtFinal: TDateTime;
                                                      const idcolaborador: Integer;
                                                      out datasEmConflito: TList<String>): Boolean;
var
  SQL : TStringList;
  Parameters : TDictionary<String, Variant>;
  FdQuery : TFDQuery;
begin
  SQL := TStringList.Create;
  Parameters := TDictionary<String, Variant>.Create;
  Result := False;
  try
    with SQL do
    begin
      BeginUpdate;
      Add('SELECT DISTINCT');
      Add('  dtinicio, dtfinal');
      Add('FROM');
      Add('  controleferias.cbperiodos');
      Add('WHERE');
      Add('  IdColaborador = :paramIdColaborador AND ');
      Add('  (dtinicio, dtfinal) OVERLAPS (:paramDtInicio, :paramDtFinal);');
      EndUpdate;
    end;

    with Parameters do
    begin
      Add('paramIdColaborador', idcolaborador);
      Add('paramDtInicio',  dtInicio);
      Add('paramDtFinal', dtFinal);
    end;

    TQueryManager.Instancia
      .CreateQuery(SQL.Text, fDaoColaborador.FdConnection, FdQuery, Parameters, False);

    if not FdQuery.IsEmpty then
    begin
      Result := True;
      datasEmConflito := TList<String>.Create;
      while Not FdQuery.Eof do
      begin
        datasEmConflito.Add(Format('%s à %s', [
          FormatDateTime('dd/mm/yyyy', FdQuery
            .FieldByName(TCbPeriodos.clDtInicio).AsDateTime),
          FormatDateTime('dd/mm/yyyy', FdQuery
            .FieldByName(TCbPeriodos.clDtFinal).AsDateTime)]));
        FdQuery.Next;
      end;
    end;

  finally
    Parameters.Free;
    FdQuery.Free;
    SQL.Free;
  end;

end;

procedure TGerenciadorColaborador.VerificarConflitosDePeriodo(const dtInicio, dtFinal: TDateTime; var tdcGrid: TDCGrid;
                                                             const flConflito: TFiltroConflitos; const idColaborador: Integer);
var
  SQL : TStringList;
  Parameters : TDictionary<String, Variant>;
  FdQuery : TFDQuery;
  Negar : String;
begin

  SQL := TStringList.Create;
  Parameters := TDictionary<String, Variant>.Create;
  try
    with SQL do
    begin
      BeginUpdate;
      Add('SELECT');
      Add('  C.login,');
      Add('  CASE');
      Add('    WHEN (dtinicio, dtfinal) OVERLAPS (:paramDtInicio, :paramDtFinal) THEN');
      Add('      ''Conflita''');
      Add('    ELSE');
      Add('      ''Não Conflita''');
      Add('  END AS validacao,');
      Add('  dtinicio,');
      Add('  dtfinal');
      Add('FROM');
      Add('  controleferias.cbperiodos CB');
      Add('LEFT JOIN controleferias.colaborador C');
      Add('ON (C.idcolaborador = CB.idcolaborador)');
      Add('WHERE CB.idcolaborador <> :paramIdColaborador');
      if flConflito <> Todos then
      begin
        Negar := IfThen(flConflito = SemConflito, 'NOT', '');
        Add(Format('AND %s (dtinicio, dtfinal) OVERLAPS (:paramDtInicio, :paramDtFinal);', [Negar]));
      end
      else
        Add(';');

      EndUpdate;
    end;

    with Parameters do
    begin
      Add('paramIdColaborador', idColaborador);
      Add('paramDtInicio',  dtInicio);
      Add('paramDtFinal', dtFinal);
    end;

    TQueryManager.Instancia
      .CreateQuery(SQL.Text, fDaoColaborador.FdConnection, FdQuery, Parameters, False);

    if not FdQuery.IsEmpty then
      tdcGrid.DataSet := FdQuery
    else
      tdcGrid.ClearTableCells;

  finally
    Parameters.Free;
    FdQuery.Free;
    SQL.Free;
  end;

end;

function TGerenciadorColaborador.LocalizarTodos(out colaboradores: TList<TColaborador>): Boolean;
begin
  Result := DaoColaborador.FindAll(colaboradores);
end;

procedure TGerenciadorColaborador.LimparTodosPeriodosPorId(const idColaborador: Integer);
begin
  DaoCbPeriodos.Delete(TColaborador.clIdColaborador, idColaborador);
end;

procedure TGerenciadorColaborador.RemoverPeriodoFeriasPorId(const idCbPeriodo, idColaborador: Integer);
var
  SqlFilter : TSQLFilterBuilder;
begin
  SqlFilter := TSQLFilterBuilder.Create;
  try
    SqlFilter
      .Add(TCbPeriodos.clIdCbPeriodo, idCbPeriodo)
      .SqlAnd
      .Add(TColaborador.clIdColaborador, idColaborador);
    DaoCbPeriodos.DeleteWhere(SqlFilter);
  finally
    SqlFilter.Free;
  end;
end;

procedure TGerenciadorColaborador.AdicionarPeriodoFeriasPorId(const dtInicio, dtFinal: TDateTime;
                                                              idColaborador: Integer);
var
  NovoCbPeriodos : TCbPeriodos;
begin
  NovoCbPeriodos := TCbPeriodos.Create;
  try
    NovoCbPeriodos.fDataInicio := dtInicio;
    NovoCbPeriodos.fDataFinal := dtFinal;
    NovoCbPeriodos.fIdColaborador := idColaborador;
    DaoCbPeriodos.Insert(NovoCbPeriodos);
  finally
    NovoCbPeriodos.Free;
  end;
end;

procedure TGerenciadorColaborador.AtualizarColaboradorPorId(const idColaborador: Integer;
                                                            alteracoes: TDictionary<String, Variant>);
begin
  DaoColaborador.Update(TColaborador.clIdColaborador, idColaborador, alteracoes);
end;

procedure TGerenciadorColaborador.ExcluirColaboradorPorId(idcolaborador: Integer);
begin
  DaoColaborador.Delete(TColaborador.clIdColaborador, idcolaborador);
end;

function TGerenciadorColaborador.LocalizarPorLogin(const nome: String;
                                                    out colaborador: TColaborador): Boolean;
begin
  Result := DaoColaborador.FindUnique(nome, TColaborador.clLogin, colaborador);
end;

function TGerenciadorColaborador.LocalizarPeriodosPorColaborador(const idcolaborador: Integer;
                                                                 out cbPeriodos: TList<TCbPeriodos>): Boolean;
begin
  Result := DaoCbPeriodos.Find(idcolaborador, TColaborador.clIdColaborador, cbPeriodos);
end;

function TGerenciadorColaborador.LocalizarTodosPeriodos(out cbPeriodos: TList<TCbPeriodos>): Boolean;
begin
  Result := DaoCbPeriodos.FindAll(cbPeriodos);
end;

function TGerenciadorColaborador.CriarColaborador(colaborador: TColaborador): Boolean;
begin
  { validar usuário aqui }
  Result := DaoColaborador.Insert(colaborador);
end;

procedure TGerenciadorColaborador.HandleException(exception: EFDDBEngineException);
var
  ConstraintName : String;
begin
  if exception.Kind = ekUKViolated then
  begin
    ConstraintName := exception[0].ObjName;
    {colaborador}
    if SameText(ConstraintName, TColaborador.constUqNmUsuario) then
      TFrmValidacaoSimples.MostrarValidacao('Operação não permitida!', 'Já existe um colaborador com este login! Verifique.', '')

    {projeto}
    else if SameText(ConstraintName, TCbProj.constUqIdColabProj) then
      TFrmValidacaoSimples.MostrarValidacao('Operação não permitida!', 'Este projeto já foi adicionado a esse colaborador.', '');

  end;
end;

end.
