unit uFeriasVisualGrid;

interface

uses
  TypInfo,
  uVisualMiscs,
  uControleProjeto,
  uControleConfiguracao,
  uControleColaborador,
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
  TFeriasPeriodosInterceptor = class(TInterfacedObject, IDCDataSetInterceptor)
    private
      procedure RenderizarPeriodos(var field: TField; var ComJSONArray: TJSONArray);

    public
      CargaLocalCbPeriodos : TList<TCbPeriodos>;
      procedure CarregarDadosLocais(var Colaborador: TColaborador);
      function GetColumnCellValue(columnValue: String): String;
      function GetDataCellValue(var field: TField; fieldName: String;
                                RowIndex: Integer; var dataSet: TDataSet): String;
      destructor Destroy; override;

  end;

  TFeriasConflitosInterceptor = class(TInterfacedObject, IDCDataSetInterceptor)
    private
      procedure RenderizarValidacoes(var field: TField; var ComJSONArray: TJSONArray);
    public
      function GetColumnCellValue(columnValue: String): String;
      function GetDataCellValue(var field: TField; fieldName: String;
                                RowIndex: Integer; var dataSet: TDataSet): String;
  end;

implementation

function TFeriasConflitosInterceptor.GetColumnCellValue(columnValue: String): String;
begin
  Result := TGlobalVisualMiscs.GetTraducaoNomeColuna(columnValue);
end;

procedure TFeriasConflitosInterceptor.RenderizarValidacoes(var field: TField; var ComJSONArray: TJSONArray);
var
  CorFonte : String;
  CorFundo : String;
  Texto : String;
begin
  Texto := field.Value;
  if Texto = 'Conflita' then
  begin
    CorFonte := '#991b1b';
    CorFundo := '#fef2f2';
  end
  else
  begin
    CorFonte := '#166534';
    CorFundo := '#ecfdf5';
  end;
  ComJSONArray.Add(TDCBadgeCellData.CreateJSONObject(CorFonte, CorFundo, Texto));
end;

function TFeriasConflitosInterceptor.GetDataCellValue(var field: TField; fieldName: String;
                                                      RowIndex: Integer; var dataSet: TDataSet): String;
var
  ComJSONArray : TJSONArray;
begin
  ComJSONArray := TJSONArray.Create;
  if field.FieldName = 'validacao' then
  begin
    RenderizarValidacoes(field, ComJSONArray);
  end
  else
  begin
    TGlobalVisualMiscs.RenderizarTextoSimples(field, ComJSONArray, '#000000');
  end;
  Result := ComJSONArray.ToString;
  ComJSONArray.Free;
end;


function TFeriasPeriodosInterceptor.GetDataCellValue(var field: TField; fieldName: String;
                                                     RowIndex: Integer; var dataset: TDataSet): String;
var
  ComJSONArray : TJSONArray;
begin
  ComJSONArray := TJSONArray.Create;
  if (fieldName = 'idcbperiodo') then
  begin
    RenderizarPeriodos(field, ComJSONArray);
    Result := ComJSONArray.ToString;
    ComJSONArray.Free;
  end
  else
    Result := VarToStr(field.AsVariant);
end;

procedure TFeriasPeriodosInterceptor.RenderizarPeriodos(var field: TField; var ComJSONArray: TJSONArray);
var
  IdCbPeriodo : Integer;
  Cores : TArray<String>;
  TemPeriodo : Boolean;
  Indice : Integer;
begin
  IdCbPeriodo := field.AsInteger;
    for var LocalCbPeriodo in CargaLocalCbPeriodos do
    begin
      if IdCbPeriodo = LocalCbPeriodo.IdCbPeriodo then
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

end;

function TFeriasPeriodosInterceptor.GetColumnCellValue(columnValue: String): String;
begin
  Result := TGlobalVisualMiscs.GetTraducaoNomeColuna(columnValue);
end;

procedure TFeriasPeriodosInterceptor.CarregarDadosLocais(var Colaborador: TColaborador);
var
  FalhaAoCarregar : Boolean;
begin
  FalhaAoCarregar := False;
  FreeAndNil(CargaLocalCbPeriodos);

  if not GerenciadorColaborador.LocalizarPeriodosPorColaborador(Colaborador.Id, CargaLocalCbPeriodos) then
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

destructor TFeriasPeriodosInterceptor.Destroy;
begin
  if Assigned(CargaLocalCbPeriodos) then
  begin
    FreeAndNil(CargaLocalCbPeriodos);
  end;
  inherited;
end;

end.
