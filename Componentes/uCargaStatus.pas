unit uCargaStatus;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, D16Utils, Vcl.ExtCtrls,
  Vcl.Imaging.GIFImg, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf,
  FireDAC.Comp.UI;

type
  TCarregamentoStatus = class(TForm)
    LblMsg: TLabel;
    Image1: TImage;
    LblStatus: TLabel;
    Shape1: TShape;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public
    procedure Mensagem(const texto: String);
    procedure Status(const texto: String);

  end;

implementation

{$R *.dfm}

procedure TCarregamentoStatus.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  (Image1.Picture.Graphic as TGIFImage).Animate := True;
  (Image1.Picture.Graphic as TGIFImage).AnimationSpeed := 5000;
  (Image1.Picture.Graphic as TGIFImage).AnimateLoop := TGIFAnimationLoop.glEnabled;
end;

procedure TCarregamentoStatus.FormShow(Sender: TObject);
begin
  TUtil.CenterForm(Self);
  LblMsg.Font.Color    := rgb(76,86,48);
  LblStatus.Font.Color := rgb(76,86,48);
  Shape1.Pen.Color     := rgb(76,86,48);
  Caption := '';
  SetFocus;
end;

procedure TCarregamentoStatus.Status(const texto: String);
begin
  LblStatus.Caption := texto;
end;

procedure TCarregamentoStatus.Mensagem(const texto: String);
begin
  LblMsg.Caption := texto;
  Application.ProcessMessages;
  TThread.Sleep(5);
end;

end.
