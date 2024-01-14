unit uControleConfiguracao;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  FireDAC.Comp.Client,
  FireDaC.Stan.Error,
  uSQLAttr,
  uSQLRTTIBuilders,
  uRepo,
  uUtility;

type
  [TDbTable('controleferias.configuracao')]
  TConfiguracao = class

    const clIdConfiguracao = 'IdConfiguracao';
    const clSection = 'Section';
    const clIdent = 'Ident';
    const clValue = 'Value';

    private
      [TDbField(clIdConfiguracao)]
      fIdConfiguracao : Integer;

      [TDbField(clSection)]
      fSection : String;

      [TDbField(clIdent)]
      fIdent : String;

      [TDbField(clValue)]
      fValue : String;

    public
      property IdConfiguracao : Integer read fIdConfiguracao;
      property Section : String read fSection;
      property Ident : String read fIdent;
      property Value : String read fValue;

  end;

  TDAOConfiguracao = class(TFdRTDao<TConfiguracao>) end;

  TGerenciadorConfiguracao = class(TInterfacedObject, IDbErrorHandler)
    private
      fDaoConfiguracao : TDAOConfiguracao;
      fClStatusAberto : String;
      fClStatusAndamento : String;
      fClStatusFinalizado : String;
      fClFgTextoDesabilitado : String;
      fClBgTextoDesabilitado : String;
      fVlMaximoDeDiasAComprir : Integer;
      fVlMinimoDeDiasEmPeriodos : Integer;
      fUltimaVersao : String;

      procedure HandleException(exception: EFDDBEngineException);

    protected
      property DaoConfiguracao : TDAOConfiguracao read fDaoConfiguracao;

    public
      constructor Create(var fdConnection: TFDConnection);
      procedure SalvarConfiguracao(const section, ident, novoValor: String);
      function GetValue(const section, ident: String): String;
      procedure CarregarConfiguracao;

      property CorStatusAberto : String read fClStatusAberto;
      property CorStatusAndamento : String read fClStatusAndamento;
      property CorStatusFinalizado : String read fClStatusFinalizado;
      property CorFgTextoDesabilitado : String read fClFgTextoDesabilitado;
      property CorBgTextoDesabilitado : String read fClBgTextoDesabilitado;
      property VlMaximoDeDiasAComprir : Integer read fVlMaximoDeDiasAComprir;
      property VlMinimoDeDiasEmPeriodos : Integer read fVlMinimoDeDiasEmPeriodos;
      property UltimaVersao : String read fUltimaVersao;

  end;

var
  GerenciadorConfiguracao : TGerenciadorConfiguracao;

implementation

constructor TGerenciadorConfiguracao.Create(var fdConnection: TFDConnection);
begin
  fDaoConfiguracao := TDAOConfiguracao.Create(fdConnection);
  fDaoConfiguracao.ErrorHandler := Self;
  CarregarConfiguracao;
end;

procedure TGerenciadorConfiguracao.SalvarConfiguracao(const section, ident, novoValor: String);
var
  SqlFilter : TSQLFilterBuilder;
  Alteracoes : TDictionary<String, Variant>;
  Parametros : TDictionary<String, Variant>;
begin
  SqlFilter := TSQLFilterBuilder.Create;
  Alteracoes := TDictionary<String, Variant>.Create;
  Parametros := TDictionary<String, Variant>.Create;
  with SqlFilter do
  begin
    AddParameterized(TConfiguracao.clSection);
    SqlAnd;
    AddParameterized(TConfiguracao.clIdent);
  end;
  try
    Alteracoes.Add(TConfiguracao.clValue, novoValor);
    Parametros.Add(TMiscUtil.CreateParam(TConfiguracao.clSection), section);
    Parametros.Add(TMiscUtil.CreateParam(TConfiguracao.clIdent), ident);
    DaoConfiguracao.UpdateWhere(SqlFilter, Alteracoes, Parametros);
  finally
    SqlFilter.Free;
    Alteracoes.Free;
    Parametros.Free;
  end;
end;

function TGerenciadorConfiguracao.GetValue(const section, ident: String): String;
var
  Parameters : TDictionary<String, Variant>;
  Configuracao : TConfiguracao;
  SqlText : String;
begin
  try
    SqlText := 'SELECT * FROM controleferias.configuracao ' +
               'WHERE section = :paramSection AND ident = :paramIdent;';
    Parameters := TDictionary<String, Variant>.Create;
    Parameters.Add('paramSection', section);
    Parameters.Add('paramIdent', ident);

    if DaoConfiguracao.CustomFindUnique(SqlText, Parameters, Configuracao) then
      Result := Configuracao.Value
    else
      Result := '';

  finally
    Parameters.Free;
    Configuracao.Free;
  end;
end;

procedure TGerenciadorConfiguracao.CarregarConfiguracao;
begin
  fUltimaVersao          := GetValue('ControleFerias', 'UltimaVersao');
  fClStatusAberto        := GetValue('VisualGridPrincipal', 'ClStatusAberto');
  fClStatusAndamento     := GetValue('VisualGridPrincipal', 'ClStatusAndamento');
  fClStatusFinalizado    := GetValue('VisualGridPrincipal', 'ClStatusFinalizado');
  fClFgTextoDesabilitado := GetValue('VisualGridPrincipal', 'ClFgTextoDesabilitado');
  fClBgTextoDesabilitado := GetValue('VisualGridPrincipal', 'ClBgTextoDesabilitado');
  fVlMaximoDeDiasAComprir   := StrToInt(GetValue('CadastroEdicaoFerias', 'VlMaximoDeDiasACumprir'));
  fVlMinimoDeDiasEmPeriodos := StrToInt(GetValue('CadastroEdicaoFerias', 'VlMinimoDeDiasEmPeriodos'));
end;

procedure TGerenciadorConfiguracao.HandleException(exception: EFDDBEngineException);
begin
  raise exception;
end;

end.
