unit uSelecaoPeriodos;

interface

uses
  uValidacaoSimples,
  uControleConfiguracao,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.WinXPickers,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  D16Utils;

type
  TFrmSelecaoPeriodo = class(TForm)
    DtPcInicio: TDateTimePicker;
    DtPcWin10Inicio: TDatePicker;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    DtPcWin10Final: TDatePicker;
    DtPcFinal: TDateTimePicker;
    BtnSelecionarPeriodo: TButton;
    Label1: TLabel;

    procedure DtPcInicioChange(Sender: TObject);
    procedure DtPcWin10InicioChange(Sender: TObject);
    procedure DtPcWin10FinalChange(Sender: TObject);
    procedure DtPcFinalChange(Sender: TObject);
    procedure BtnSelecionarPeriodoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DtPcInicioKeyPress(Sender: TObject; var Key: Char);
    procedure DtPcFinalKeyPress(Sender: TObject; var Key: Char);

  private
    fDtInicio : TDate;
    fDtFinal  : TDate;

    function ValidarMudanca(): Boolean;

  public
    property DataInicio : TDate read fDtInicio;
    property DataFinal : TDate read fDtFinal;
  end;

implementation

{$R *.dfm}

function TFrmSelecaoPeriodo.ValidarMudanca(): Boolean;
var
  VlMinimoDeDiasEmPeriodos : Integer;
  MsgTitulo : String;
  MsgDescricao : String;
  MsgDica : String;
  DtInicio : TDate;
  DtFinal : TDate;
begin

  VlMinimoDeDiasEmPeriodos := GerenciadorConfiguracao.VlMinimoDeDiasEmPeriodos;
  DtInicio := DtPcInicio.Date;
  DtFinal := DtPcFinal.Date;
  Result := True;

  if DtInicio > DtFinal then
  begin
    Result := False;
    TFrmValidacaoSimples.MostrarValidacao('Per�odo inv�lido!', 'Data final n�o poder ser inferior a data de inicio.', '');
  end
  else if (DtInicio < Now) or (DtFinal < Now) then
  begin
    Result := False;
    TFrmValidacaoSimples.MostrarValidacao(
      'Per�odo n�o permitido!',
      'O per�odo informado n�o pode ser menor que o da m�quina!',
      '');
  end
  else if (DtFinal - DtInicio) < VlMinimoDeDiasEmPeriodos then
  begin
    Result := False;
    TFrmValidacaoSimples.MostrarValidacao(
      'Per�odo n�o permitido!',
      Format('O per�odo entre as datas n�o pode ser menor que %d dia(s).', [VlMinimoDeDiasEmPeriodos]),
      '� poss�vel alterar o valor m�nimo de dias por per�odo em Inicio / Op��es ');
  end;
end;

procedure TFrmSelecaoPeriodo.BtnSelecionarPeriodoClick(Sender: TObject);
begin
  if ValidarMudanca then
  begin
    fDtInicio := DtPcInicio.Date;
    fDtFinal := DtPcFinal.Date;
    ModalResult := mrOk;
    CloseModal;
  end;
end;

procedure TFrmSelecaoPeriodo.DtPcFinalKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #9) or (Key = #13) then
  begin
    BtnSelecionarPeriodo.SetFocus;
  end;
end;

procedure TFrmSelecaoPeriodo.DtPcInicioKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #9) or (Key = #13) then
  begin
    DtPcFinal.SetFocus;
  end;
end;

procedure TFrmSelecaoPeriodo.DtPcFinalChange(Sender: TObject);
begin
  DtPcWin10Final.Date := DtPcFinal.Date;
end;

procedure TFrmSelecaoPeriodo.DtPcInicioChange(Sender: TObject);
begin
  DtPcWin10Inicio.Date := DtPcInicio.Date;
end;

procedure TFrmSelecaoPeriodo.DtPcWin10FinalChange(Sender: TObject);
begin
  DtPcFinal.Date := DtPcWin10Final.Date;
end;

procedure TFrmSelecaoPeriodo.DtPcWin10InicioChange(Sender: TObject);
begin
   DtPcInicio.Date := DtPcWin10Inicio.Date;
end;

procedure TFrmSelecaoPeriodo.FormCreate(Sender: TObject);
begin
  TUtil.CenterForm(Self);
  ModalResult := mrCancel;
  DtPcInicio.Date := Now;
  DtPcWin10Inicio.Date := DtPcInicio.Date;
  DtPcFinal.Date := Now;
  DtPcWin10Final.Date := DtPcFinal.Date;
end;

end.
