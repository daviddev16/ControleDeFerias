unit uDCGridGlobal;

interface

uses
  D16Utils,
  uUtility,
  D16Grids,
  System.JSON,
  System.Generics.Collections,
  uControleConfiguracao,
  uControleProjeto,
  SysUtils,
  DB;

type
  TDCGridCommons = class
    public
     class function RenderizarProjeto(var cargaProjetos: TList<Tprojeto>; var field: TField;
                                      var ComJSONArray: TJSONArray): Boolean;

  end;

implementation

{
  Retorna false caso não tenha projetos
}
class function TDCGridCommons.RenderizarProjeto(var cargaProjetos: TList<Tprojeto>; var field: TField;
                                                var ComJSONArray: TJSONArray): Boolean;
var
  QueryIdProjetos : TArray<Variant>;
begin
  Result := False;
  QueryIdProjetos := TMiscUtil.GetFieldList(Field);
  for var QrIdProjeto in QueryIdProjetos do
    for var LocalProjeto in cargaProjetos do
    begin
      if QrIdProjeto = LocalProjeto.IdProjeto then
      begin
        ComJSONArray.Add(
          TDCBadgeCellData.CreateJSONObject(
            LocalProjeto.CorTexto,
            LocalProjeto.CorFundo,
            LocalProjeto.Nome));
        Result := True;
      end;
    end;
  SetLength(QueryIdProjetos, 0);
end;

end.
