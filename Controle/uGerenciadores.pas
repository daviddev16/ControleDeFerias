unit uGerenciadores;


interface

uses
  uRepo,
  uControleProjeto,
  uControleColaborador,
  uControleConfiguracao,
  uControleCor,
  uVisualMiscs,
  uConexao,
  uControleUsuario,
  System.SysUtils,
  FireDAC.Comp.Client;

type
  TGerenciador = class
    class procedure Inicializar;
  end;

var
  FdConnection : TFdConnection;
  DaoUsuario : TDAOUsuario;

implementation

class procedure TGerenciador.Inicializar;
var
  FdDbConn : TFdDbConn;
begin
  TQueryManager.Inicializar;

  if not TFdDbConn.CarregarConexao(FdDbConn) then
  begin
    raise Exception.Create('N�o foi poss�vel carregar as informa��es para login.');
    Exit;
  end;

  FDConnection := TFDConnection.Create(nil);
  FDConnection.Params.Add(Format('Server=%s', [FdDbConn.Host]));
  FDConnection.Params.Add(Format('Database=%s', [FdDbConn.Database]));
  FDConnection.Params.Add('User_Name=CFADMIN');
  FDConnection.Params.Add('Password=abc@123');
  FDConnection.Params.Add('DriverID=PG');
  FDConnection.Connected := True;

  if not FdConnection.Connected then
  begin
    raise Exception.Create('N�o foi poss�vel se conectar ao banco de dados.');
    Exit;
  end;

  DaoUsuario := TDAOUsuario.Create(FdConnection);
  TGlobalVisualMiscs.InicializarGlobalVisualMiscs;
  GerenciadorConfiguracao := TGerenciadorConfiguracao.Create(FdConnection);
  GerenciadorCores := TGerenciadorCores.Create(FdConnection);
  GerenciadorColaborador := TGerenciadorColaborador.Create(FDConnection);
  GerenciadorProjeto := TGerenciadorProjeto.Create(FdConnection);

end;

end.
