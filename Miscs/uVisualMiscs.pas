unit uVisualMiscs;

interface

uses
  Vcl.Dialogs,
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Variants,
  System.JSON,
  D16Grids,
  DB;

type
  TEstadoEdicao = (Preview, EditandoExistente, EditandoNovo);

  TGlobalVisualMiscs = class
    public
      class procedure InicializarGlobalVisualMiscs;

      class procedure InicializarTraducaoColunas;
      class procedure InicializarPeriodoCores;
      class procedure RenderizarTextoSimples(var field: TField; var ComJSONArray: TJSONArray;
                                             const corTexto : String);

      class function ConfirmarSimples(descricao: String): Integer;
      class function GetCorPeriodo(valor: Integer) : TArray<String>;
      class function GetTraducaoNomeColuna(nomeColuna: String): String;
  end;

var
  TraducaoColunas : TDictionary<String, String>;
  CorPeriodos : TList<String>;

implementation

class procedure TGlobalVisualMiscs.InicializarGlobalVisualMiscs;
begin
  InicializarTraducaoColunas;
  InicializarPeriodoCores;
end;

class function TGlobalVisualMiscs.GetCorPeriodo(valor: Integer) : TArray<String>;
var
  Index : Integer;
begin
  Index := (valor mod CorPeriodos.Count + CorPeriodos.Count) mod CorPeriodos.Count;
  Result := CorPeriodos[Index].Split(['|']);
end;

class function TGlobalVisualMiscs.GetTraducaoNomeColuna(nomeColuna: String): String;
begin
  Result := TraducaoColunas[nomeColuna];
end;

class procedure TGlobalVisualMiscs.InicializarTraducaoColunas;
begin

  if (TraducaoColunas <> nil) and (TraducaoColunas.Count > 0) then
    Exit;

  TraducaoColunas := TDictionary<String, String>.Create;
  with TraducaoColunas do
  begin
    Add('login', 'Usuário');
    Add('dscolaborador', 'Nome do Colaborador');
    Add('observacao', 'Observação');
    Add('dtinicios', 'De');
    Add('dtfinais', 'Até');
    Add('dtinicio', 'Começando em');
    Add('dtfinal', 'Terminando em');
    Add('validacao', 'Validação');
    Add('projetos', 'Projetos');
    Add('totaldiasprevistos', 'Dias Previstos');
    Add('totaldiasregistrados', 'Dias Registrados');
    Add('dtperiodos', 'Períodos');
    Add('idcbperiodos', 'Períodos');
    Add('idcbperiodo', 'Períodos');
    Add('idcolaborador', 'Identificador');
    Add('idcbp', 'Id');
    Add('icone',' ');
  end;
end;

class procedure TGlobalVisualMiscs.InicializarPeriodoCores;
begin

  if (CorPeriodos <> nil) and (CorPeriodos.Count > 0) then
    Exit;

  CorPeriodos := TList<String>.Create;
  with CorPeriodos do
  begin
    Add('#ecfeff|#0e7490');
    Add('#eef2ff|#4338ca');
    Add('#fffbeb|#d97706');
    Add('#f7fee7|#4d7c0f');
    Add('#fef2f2|#b91c1c');
  end;

end;

class procedure TGlobalVisualMiscs.RenderizarTextoSimples(var field: TField; var ComJSONArray: TJSONArray;
                                                          const corTexto : String);
begin
  ComJSONArray.Add(TDCTextCellData.CreateJSONObject(corTexto, VarToStr(field.Value)));
end;

class function TGlobalVisualMiscs.ConfirmarSimples(descricao: String): Integer;
begin
   Result := MessageDlg(descricao, TMsgDlgType.mtConfirmation, [mbYes, mbCancel], 0)
end;

end.
