unit uOpcoes;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Generics.Collections,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Tabs,
  Vcl.DockTabSet,
  uControleCor,
  uControleConfiguracao,
  D16Utils,
  Vcl.Samples.Spin;

type
  TFrmOpcoes = class(TForm)
    GpBxCores: TGroupBox;
    ClBxStatusAberto: TColorBox;
    LblStatusAberto: TLabel;
    PnStatusAberto: TPanel;
    PnStatusAndamento: TPanel;
    LblStatusAndamento: TLabel;
    ClBxStatusAndamento: TColorBox;
    PnStatusFinalizado: TPanel;
    LblStatusFinalizado: TLabel;
    ClBxStatusFinalizado: TColorBox;
    BtnSalvarCfg: TButton;
    GpBxCfgPeriod: TGroupBox;
    SpnVlMaxDiasAComprir: TSpinEdit;
    PnVlMaxDaC: TPanel;
    LblMaxDiasAComprir: TLabel;
    PnPeriodoMinDFerias: TPanel;
    LblPeriodoMinDFerias: TLabel;
    SpnPeriodoMinDFerias: TSpinEdit;
    procedure FormShow(Sender: TObject);
    procedure BtnSalvarCfgClick(Sender: TObject);

  private
    CargaCorTonalidades : TList<TCorTonalidade>;
    ComponentesConfigAlteravel : TList<TWinControl>;

    procedure ExecutarCargaDados;
    procedure CarregarConfiguracoesNaTela;

    procedure EventoAlteracaoComponente(Sender: TObject);

    procedure InicializarClBxConfiguravel(var colorBox: TColorBox; const section, ident: String);
    procedure InicializarSpinnerConfiguravel(var spinEdt: TSpinEdit; const section, ident: String);


    procedure RegistrarAlteracaoComponente(control: TWinControl; const vlNovo: String);
    procedure RegistrarComponente(control: TWinControl; const vlAtual, section, ident: String);

    procedure ProcessarAlteracoesESalvar;
    procedure ProcessarAlteracoesCompoente(control: TWinControl);

  public
    destructor Destroy; override;
  end;

var
  FrmOpcoes: TFrmOpcoes;

implementation

{$R *.dfm}

procedure TFrmOpcoes.FormShow(Sender: TObject);
begin
  TUtil.CenterForm(Self);
  ComponentesConfigAlteravel := TObjectList<TWinControl>.Create;
  CarregarConfiguracoesNaTela;
end;

{
  HelpContext armaneza a configuração por componente em String da seguinte forma:
  [cfgNova|cfgAtual|section|ident]. Este esquema será utilizado para gravar as alterações
  no banco de dados.
}
procedure TFrmOpcoes.BtnSalvarCfgClick(Sender: TObject);
begin
  ProcessarAlteracoesESalvar;
  GerenciadorConfiguracao.CarregarConfiguracao;
  ModalResult := mrOk;
  CloseModal;
end;

procedure TFrmOpcoes.CarregarConfiguracoesNaTela;
begin
  ExecutarCargaDados;
  InicializarClBxConfiguravel(ClBxStatusAberto,        'VisualGridPrincipal',  'ClStatusAberto');
  InicializarClBxConfiguravel(ClBxStatusAndamento,     'VisualGridPrincipal',  'ClStatusAndamento');
  InicializarClBxConfiguravel(ClBxStatusFinalizado,    'VisualGridPrincipal',  'ClStatusFinalizado');
  InicializarSpinnerConfiguravel(SpnVlMaxDiasAComprir, 'CadastroEdicaoFerias', 'VlMaximoDeDiasAComprir');
  InicializarSpinnerConfiguravel(SpnPeriodoMinDFerias, 'CadastroEdicaoFerias', 'VlMinimoDeDiasEmPeriodos');
end;

procedure TFrmOpcoes.InicializarSpinnerConfiguravel(var spinEdt: TSpinEdit; const section, ident: String);
var
  CfgValorAtual : String;
begin
  CfgValorAtual := GerenciadorConfiguracao.GetValue(section, ident);
  if not String.IsNullOrWhiteSpace(CfgValorAtual) then
  begin
    writeln(IntToStr(StrToInt(CfgValorAtual)));
    spinEdt.Value := StrToInt(CfgValorAtual);
    spinEdt.Update;
    RegistrarComponente(spinEdt, CfgValorAtual, section, ident);
    spinEdt.OnChange := EventoAlteracaoComponente;
  end;
end;

procedure TFrmOpcoes.InicializarClBxConfiguravel(var colorBox: TColorBox; const section, ident: String);
var
  CfgValorAtual : String;
begin
  colorBox.Items.Clear;
  CfgValorAtual := GerenciadorConfiguracao.GetValue(section, ident);
  if not String.IsNullOrWhiteSpace(CfgValorAtual) then
  begin
    colorBox.Items.AddObject('Cor Atual', TObject(TUtil.HexToColor(CfgValorAtual)));
    for var corTonalidade in CargaCorTonalidades do
    begin
      colorBox.Items.AddObject(corTonalidade.Nome, TObject(corTonalidade.Cor));
    end;
    colorBox.Selected := TColor(colorBox.Items.Objects[0]);
    RegistrarComponente(colorBox, CfgValorAtual, section, ident);
    colorBox.OnSelect := EventoAlteracaoComponente;
  end;
end;

procedure TFrmOpcoes.RegistrarComponente(control: TWinControl; const vlAtual, section, ident: String);
begin
  if String.IsNullOrWhiteSpace(control.HelpKeyword) then
  begin
    control.HelpKeyword := String.Join('|', [vlAtual, vlAtual, section, ident]);
    ComponentesConfigAlteravel.Add(control);
  end;
end;

procedure TFrmOpcoes.RegistrarAlteracaoComponente(control: TWinControl; const vlNovo: String);
var
  CfgStrArray : TArray<String>;
begin
 if not String.IsNullOrWhiteSpace(control.HelpKeyword) then
  begin
    CfgStrArray := control.HelpKeyword.Split(['|']);
    if Length(CfgStrArray) = 4 then
    begin
      CfgStrArray := control.HelpKeyword.Split(['|']);
      CfgStrArray[0] := vlNovo;
      control.HelpKeyword := String.Join('|', CfgStrArray);
      SetLength(CfgStrArray, 0);
    end
    else
      ShowMessage(Format('%s inicializado incorretamente.', [control.Name]));
  end;
end;

procedure TFrmOpcoes.ProcessarAlteracoesCompoente(control: TWinControl);
var
  CfgStrArray : TArray<String>;
begin
   if not String.IsNullOrWhiteSpace(control.HelpKeyword) then
    CfgStrArray := control.HelpKeyword.Split(['|']);
    if not SameText(CfgStrArray[0], CfgStrArray[1]) then
    begin
      GerenciadorConfiguracao.SalvarConfiguracao(CfgStrArray[2], CfgStrArray[3], CfgStrArray[0]);
    end;
end;

procedure TFrmOpcoes.ProcessarAlteracoesESalvar;
begin
  for var compConfigAlt in ComponentesConfigAlteravel do
    ProcessarAlteracoesCompoente(compConfigAlt);
end;

procedure TFrmOpcoes.EventoAlteracaoComponente(Sender: TObject);
var
  EvtColorBox : TColorBox;
  EvtSpinEdit : TSpinEdit;
begin
  if Sender is TColorBox then
  begin
    EvtColorBox := Sender as TColorBox;
    RegistrarAlteracaoComponente(EvtColorBox, TUtil.ColorToHex(EvtColorBox.Selected));
  end
  else if Sender is TSpinEdit then
  begin
    EvtSpinEdit := Sender as TSpinEdit;
    RegistrarAlteracaoComponente(EvtSpinEdit, IntToStr(EvtSpinEdit.Value));
  end;
end;

procedure TFrmOpcoes.ExecutarCargaDados;
begin
  if Assigned(CargaCorTonalidades) then
    CargaCorTonalidades.Free;

  GerenciadorCores.LocalizarTodas(CargaCorTonalidades);
end;


destructor TFrmOpcoes.Destroy;
begin
  if Assigned(CargaCorTonalidades) then
    FreeAndNil(CargaCorTonalidades);

  if Assigned(ComponentesConfigAlteravel) then
    FreeAndNil(ComponentesConfigAlteravel);

  inherited;
end;

end.
