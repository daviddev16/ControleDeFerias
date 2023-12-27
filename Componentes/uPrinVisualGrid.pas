unit uPrinVisualGrid;

{
  *******************************************************************************
  *                                                                             *
  *    uPrinVisualGrid - Define como será a renderização da grid principal      *
  *                                                                             *
  *    Autor: David Duarte Pinheiro                                             *
  *    Github: daviddev16                                                       *
  *                                                                             *
  *******************************************************************************
}

interface

uses
  TypInfo,
  uVisualMiscs,
  uControleProjeto,
  uControleConfiguracao,
  uControleColaborador,
  uDCGridGlobal,
  uUtility,
  Vcl.Forms,
  FireDAC.Comp.Client,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.StrUtils,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.VarUtils,
  System.DateUtils,
  System.JSON,
  Vcl.Dialogs,
  D16Utils,
  D16Grids,
  DB;

type
  TMainGridInterceptor = class(TInterfacedObject, IDCDataSetInterceptor)
  private
    CargaLocalProjetos : TList<TProjeto>;
    CargaLocalCbPeriodos : TList<TCbPeriodos>;

    function GetCalcularCorTextoSimples(var dataSet: TDataSet): String;
    procedure RenderizarPeriodos(var field: TField; var ComJSONArray: TJSONArray);

  public
    procedure CarregarDadosLocais;
    function GetColumnCellValue(columnValue: String): String;
    function GetDataCellValue(var field: TField; fieldName: String;
                              RowIndex: Integer; var dataSet: TDataSet): String;

  end;

implementation

function TMainGridInterceptor.GetDataCellValue(var field: TField; fieldName: String;
                                               RowIndex: Integer; var dataSet: TDataSet): String;
var
  ComJSONArray : TJSONArray;
  CorTextoSimples : String;
begin
  CorTextoSimples := GetCalcularCorTextoSimples(dataSet);
  ComJSONArray := TJSONArray.Create;

  if fieldName = 'projetos' then
  begin
    if not TDCGridCommons.RenderizarProjeto(CargaLocalProjetos, field, ComJSONArray) then
    begin
      ComJSONArray.Add(
        TDCBadgeCellData.CreateJSONObject(
          GerenciadorConfiguracao.CorFgTextoDesabilitado,
          GerenciadorConfiguracao.CorBgTextoDesabilitado,
          'Sem projeto'));
    end;
  end
  else if fieldName = 'idcbperiodos' then
    RenderizarPeriodos(field, ComJSONArray)

  else if MatchText(fieldName, ['login', 'dscolaborador','observacao',
                                'totaldiasprevistos', 'totaldiasregistrados', 'icone']) then
    TGlobalVisualMiscs.RenderizarTextoSimples(field, ComJSONArray, CorTextoSimples);

  Result := ComJSONArray.ToString;
  ComJSONArray.Free;
end;

procedure TMainGridInterceptor.RenderizarPeriodos(var field: TField; var ComJSONArray: TJSONArray);
var
  QueryIdCbPeriodos : TArray<Variant>;
  Cores : TArray<String>;
  TemPeriodo : Boolean;
  Indice : Integer;
begin
  QueryIdCbPeriodos := TMiscUtil.GetFieldList(Field);
  for var QrIdCbPeriodo in QueryIdCbPeriodos do
    for var LocalCbPeriodo in CargaLocalCbPeriodos do
    begin
      if QrIdCbPeriodo = LocalCbPeriodo.IdCbPeriodo then
      begin
        if (LocalCbPeriodo.DataInicio <> 0) and (LocalCbPeriodo.DataFinal <> 0) then
        begin
          Cores := TGlobalVisualMiscs.GetCorPeriodo(Indice);
          ComJSONArray.Add(
            TDCBadgeCellData.CreateJSONObject(
              Cores[1], Cores[0],
              FormatDateTime('dd/mm/yyyy', LocalCbPeriodo.DataInicio) + ' 🡒 '
            + FormatDateTime('dd/mm/yyyy', LocalCbPeriodo.DataFinal)));
          Inc(Indice);
          TemPeriodo := True;
        end
      end;
    end;
  if not TemPeriodo then
  begin
    ComJSONArray.Add(
      TDCBadgeCellData.CreateJSONObject(
        GerenciadorConfiguracao.CorFgTextoDesabilitado,
        GerenciadorConfiguracao.CorBgTextoDesabilitado,
        'Sem período definido'));
  end;
  SetLength(QueryIdCbPeriodos, 0);
end;

function TMainGridInterceptor.GetCalcularCorTextoSimples(var dataSet: TDataSet): String;
var
  DiasPrevistos : Integer;
  DiasCompridos : Integer;
begin
  DiasPrevistos := dataSet.FieldByName('totaldiasprevistos').AsInteger;
  DiasCompridos := dataSet.FieldByName('totaldiasregistrados').AsInteger;

  if DiasCompridos = 0 then
    Result := GerenciadorConfiguracao.CorStatusAberto

  else if (DiasCompridos >= DiasPrevistos) then
    Result := GerenciadorConfiguracao.CorStatusFinalizado

  else if (DiasCompridos < DiasPrevistos) then
    Result := GerenciadorConfiguracao.CorStatusAndamento;

end;

procedure TMainGridInterceptor.CarregarDadosLocais;
var
  FalhaAoCarregar : Boolean;
begin
  FalhaAoCarregar := False;

  FreeAndNil(CargaLocalCbPeriodos);
  FreeAndNil(CargaLocalProjetos);

  if not GerenciadorProjeto.LocalizarTodos(CargaLocalProjetos) then
  begin
    FalhaAoCarregar := True;
    ShowMessage('Não foi possível carregar os projetos.');
  end;
  if not GerenciadorColaborador.LocalizarTodosPeriodos(CargaLocalCbPeriodos) then
  begin
    FalhaAoCarregar := True;
    ShowMessage('Não foi possível carregar os periodos.');
  end;
  if FalhaAoCarregar then
  begin
    ShowMessage('Houve algum problema ao recuperar os dados do banco para os dados locais. Encerrando.');
    Application.Terminate;
  end;
end;

function TMainGridInterceptor.GetColumnCellValue(columnValue: String): String;
begin
  Result := TGlobalVisualMiscs.GetTraducaoNomeColuna(columnValue);
end;


end.
