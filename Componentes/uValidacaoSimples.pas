unit uValidacaoSimples;

interface

uses
  Winapi.Windows,
  Winapi.MMSystem,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Imaging.pngimage,
  Vcl.ExtCtrls,
  Vcl.Imaging.GIFImg,
  D16Utils;

type
  TFrmValidacaoSimples = class(TForm)
    Image1: TImage;
    LblTitulo: TLabel;
    LblDescricao: TLabel;
    LblDica: TLabel;
    BtnCorrigir: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtnCorrigirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
    fMsgTitulo : String;
    fMsgDescricao : String;
    fMsgDica : String;

    procedure SetDica(const msgDica: String);
    procedure SetDescricao(const msgDescricao: String);
    procedure SetTitulo(const msgTitulo: String);

  public
    class procedure MostrarValidacao(const msgTitulo, msgDesc, msgDica: String);

  end;

var
  FrmValidacaoSimples: TFrmValidacaoSimples;

implementation

{$R *.dfm}

class procedure TFrmValidacaoSimples.MostrarValidacao(const msgTitulo, msgDesc, msgDica: String);
var
  FrmValidacao : TFrmValidacaoSimples;
begin
  FrmValidacao := TFrmValidacaoSimples.Create(nil);
  try
    FrmValidacao.SetDica(msgDica);
    FrmValidacao.SetDescricao(msgDesc);
    FrmValidacao.SetTitulo(msgTitulo);
    FrmValidacao.ShowModal;
  finally
    FrmValidacao.Free;
  end;
end;

procedure TFrmValidacaoSimples.BtnCorrigirClick(Sender: TObject);
begin
  ModalResult := mrOk;
  CloseModal;
end;

procedure TFrmValidacaoSimples.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ModalResult := mrCancel;
end;

procedure TFrmValidacaoSimples.FormShow(Sender: TObject);
begin
  TUtil.CenterForm(Self);
  LblDica.Caption := fMsgDica;
  LblTitulo.Caption := fMsgTitulo;
  LblDescricao.Caption := fMsgDescricao;
  PlaySound('SystemHand', HInstance, $00010000 or $0001);
end;

procedure TFrmValidacaoSimples.SetDica(const msgDica: String);
begin
  if String.IsNullOrWhiteSpace(msgDica) then
    fMsgDica := ''
  else
    fMsgDica := Format('Dica: %s', [msgDica]);
end;

procedure TFrmValidacaoSimples.SetDescricao(const msgDescricao: String);
begin
   if String.IsNullOrWhiteSpace(msgDescricao) then
    fMsgDescricao := 'Algum parâmetro é inválido. Verifique.'
   else
    fMsgDescricao := msgDescricao;
end;


procedure TFrmValidacaoSimples.SetTitulo(const msgTitulo: String);
begin
   if String.IsNullOrWhiteSpace(msgTitulo) then
    fMsgTitulo := 'Algum parâmetro é inválido. Verifique.'
   else
    fMsgTitulo := msgTitulo;
end;


end.
