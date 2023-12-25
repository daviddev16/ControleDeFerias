unit uGerenciadores;


interface

uses
  uRepo,
  uControleProjeto,
  uControleColaborador,
  uControleConfiguracao,
  uControleCor,
  uVisualMiscs,
  FireDAC.Comp.Client;

type
  TGerenciador = class
    class procedure Inicializar;
  end;

var
  FdConnection : TFdConnection;

implementation

class procedure TGerenciador.Inicializar;
begin
  WriteLn('Inicializando TQueryManager.');
  TQueryManager.Inicializar;

  FDConnection := TFDConnection.Create(nil);
  FDConnection.Params.Add('Server=localhost');
  FDConnection.Params.Add('Database=DB_CONTROLE_FERIAS_113');
  FDConnection.Params.Add('User_Name=postgres');
  FDConnection.Params.Add('Password=#abc123#');
  FDConnection.Params.Add('DriverID=PG');
  FDConnection.Connected := True;

  TGlobalVisualMiscs.InicializarGlobalVisualMiscs;

  GerenciadorConfiguracao := TGerenciadorConfiguracao.Create(FdConnection);
  GerenciadorCores := TGerenciadorCores.Create(FdConnection);
  GerenciadorColaborador := TGerenciadorColaborador.Create(FDConnection);
  GerenciadorProjeto := TGerenciadorProjeto.Create(FdConnection);

end;

end.
