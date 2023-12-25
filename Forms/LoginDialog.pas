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
  D16Utils, Vcl.Imaging.pngimage;

type
  TLoginForm = class(TForm)
    EdtLogin: TLabeledEdit;
    EdtSenha: TLabeledEdit;
    BtnLogin: TButton;
    Image1: TImage;
    Label1: TLabel;
    procedure BtnLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    DaoUsuario : TDAOUsuario;
    DaoProjeto : TDAOProjeto;
    { Private declarations }
  public
    { Public declarations }
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

  StrLogin := String.Copy(EdtLogin.Text);
  DaoUsuario.FindByLogin(StrLogin, Usuario);

  if Assigned(Usuario) then
  begin
    if TUtil.HashStr(EdtSenha.Text) <> Usuario.SenhaHash then
    begin
      ShowMessage('Senha incorreta.');
    end
    else
    begin
      Hide;
      FormPrincipal.Show;
    end;
  end
  else
  begin
    ShowMessage('Este usuário não foi encontrado no banco de dados.');
  end;


end;

procedure TLoginForm.Button1Click(Sender: TObject);
var
  ChangesDict : TDictionary<String, Variant>;
  Proj : TProjeto;
  Proj2 : TProjeto;
var
  I : Integer;
begin

  ShowMessage( GerenciadorConfiguracao.GetValue('VisualGridPrincipal', 'ClBgTextoDesabilitado') );

{  for I := 24 to 1020 do
  begin
     GerenciadorColaborador.AdicionarProjeto(I, 'Shop');
  end;}
  {ShowMessage( GerenciadorConfiguracao.GetConfiguracao('clAberto') );

  ChangesDict := TDictionary<String, Variant>.Create;
  ChangesDict.Add(TProjeto.cfDsProj, 'Alterdata IShop');
  ChangesDict.Add(TProjeto.cfNmProj, 'WSHOP');
  ChangesDict.Add(TProjeto.cfClFundo, 'FUNDO!!');


  Proj2 := TProjeto.Create;

  DaoProjeto.FindByNome('Shop1', Proj);

  if Proj <> nil then
  begin
    DaoProjeto.UpdateById(Proj.IdProjeto, ChangesDict);
    //DaoProjeto.Insert(Proj2);
    ShowMessage(Proj.Descricao);

    //DaoProjeto.DeleteById(Proj.IdProjeto);
  end;

  Proj.Free;
   }
end;

procedure TLoginForm.FormCreate(Sender: TObject);
var
  FDConnection1 : TFDConnection;
  Usuario : TUsuario;
  ClassType : TRttiType;
begin

  ClassType := TRttiContext.Create.GetType(TypeInfo(TUsuario));

  EdtLogin.Text := 'SUPERVISOR';
  EdtSenha.Text := '123';

  TUtil.CenterForm(LoginForm);
  Label1.Caption := 'Controle de férias - ' + GerenciadorConfiguracao.UltimaVersao;

  FDConnection1 := TFDConnection.Create(nil);
  FDConnection1.Params.Add('Server=localhost');
  FDConnection1.Params.Add('Database=DB_CONTROLE_FERIAS_113');
  FDConnection1.Params.Add('User_Name=CFADMIN');
  FDConnection1.Params.Add('Password=abc@123');
  FDConnection1.Params.Add('DriverID=PG');
  FDConnection1.Connected := True;

  DaoUsuario := TDAOUsuario.Create(FDConnection1);
  DaoProjeto := TDAOProjeto.Create(FDConnection1);


end;

end.
