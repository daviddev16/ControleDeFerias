unit LoginDialog;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  uRepo,
  uControleUsuario,
  uControleProjeto,
  uControleColaborador,
  uControleConfiguracao,
  FireDAC.Comp.Client,
  FireDAC.Stan.Error,
  uGerenciadores,
  D16Utils,
  Vcl.Imaging.pngimage;

type
  TLoginForm = class(TForm)
    EdtLogin: TLabeledEdit;
    EdtSenha: TLabeledEdit;
    BtnLogin: TButton;
    Image1: TImage;
    Label1: TLabel;
    procedure BtnLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public
    Logado : Boolean;

  end;

var
  LoginForm: TLoginForm;

implementation

{$R *.dfm}

uses uPrincipal;

procedure TLoginForm.BtnLoginClick(Sender: TObject);
var
  Usuario : TUsuario;
  StrLogin : string;
begin
  if String.IsNullOrWhiteSpace(EdtLogin.Text) then
  begin
    ShowMessage('Login inválido.');
    Exit;
  end;

  StrLogin := EdtLogin.Text;
  DaoUsuario.FindByLogin(StrLogin, Usuario);

  if Assigned(Usuario) then
  begin
    if TUtil.HashStr(EdtSenha.Text) <> Usuario.SenhaHash then
    begin
      ShowMessage('Senha incorreta.');
    end
    else
    begin
      ModalResult := mrOk;
      Logado := True;
      CloseModal;
    end;
  end
  else
  begin
    ShowMessage('Este usuário não foi encontrado no banco de dados.');
  end;
end;

procedure TLoginForm.FormCreate(Sender: TObject);
begin
  Logado := False;
  Label1.Caption := 'Controle de férias - ' + GerenciadorConfiguracao.UltimaVersao;
  EdtLogin.Text := 'SUPERVISOR';
  EdtSenha.Text := '123';
end;


end.
