unit uControleUsuario;

{ NÃO IMPLEMENTADO AINDA }

interface

uses
  SysUtils,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  uRepo,
  uUtility,
  uSQLAttr,
  FireDAC.Comp.Client;

type

  [TDbTable('controleferias.usuarios')]
  TUsuario = class
    private

      [TDbSeqId]
      [TDbField('idusuario')]
      fIdUsuario : Integer;

      [TDbField('login')]
      fLogin : String;

      [TDbField('senha')]
      fSenhaHash : String;

      [TDbField('stativo')]
      fStatus : Boolean;

      [TDbField('dsusuario')]
      fDsUsuario : String;

    private
      procedure SetLogin(login: String);
    public
      property Login: String read fLogin write SetLogin;
      property SenhaHash: String read fSenhaHash write fSenhaHash;
      property IdUsuario: Integer read fIdUsuario write fIdUsuario;
      property Status: Boolean read fStatus write fStatus;
      property DsUsuario: String read fDsUsuario write fDsUsuario;

  end;

  TDAOUsuario = class(TFdRTDao<TUsuario>)
    public
      function FindById(usuarioId: Integer; out usuario: TUsuario): Boolean;
      function FindByLogin(login: String; out usuario: TUsuario): Boolean;
  end;

  TGerenciadorUsuario = class
  { validar entidade e interagir com a dao }
  end;

implementation

procedure TUsuario.SetLogin(login: String);
begin
  if String.IsNullOrWhitespace(login) then
    raise TValidationException.Create('O nome de usuário não pode ser vazio.');

  Self.fLogin := login;
end;

function TDAOUsuario.FindByLogin(login: String; out usuario: TUsuario): Boolean;
begin
  Result := FindUnique(login, 'Login', usuario);
end;

function TDAOUsuario.FindById(usuarioId: Integer; out usuario: TUsuario): Boolean;
begin
  Result := FindUnique(usuarioId, 'IdUsuario', usuario);
end;

end.



