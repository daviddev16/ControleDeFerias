unit uGerenciadorColaborador;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Math,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  uControleConfiguracao,
  uControleProjeto,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  System.Generics.Collections,
  Vcl.ExtCtrls,
  uControleCor,
  D16Custom,
  D16Utils,
  uControleColaborador,
  Vcl.Imaging.pngimage,
  Vcl.Mask, Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  System.ImageList,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  uVisualMiscs,
  uValidacaoSimples;

type
  TFrmGerenciadorColaborador = class(TForm)
    GpBxCb: TGroupBox;
    LblLoginColab: TLabeledEdit;
    BtnSair: TButton;
    LblDsColab: TLabeledEdit;
    Panel1: TPanel;
    BtnNovo: TSpeedButton;
    CmbBxSelecaoColaborador: TComboBox;
    _Separador01: TShape;
    LblLocalizarColab: TLabel;
    _Separador02: TShape;
    BtnExcluir: TSpeedButton;
    BtnSalvarAlteracoes: TButton;
    PnVisualizacao: TPanel;
    BtnEditar: TSpeedButton;
    PnEdicaoColab: TPanel;
    BtnCancelar: TButton;
    SpnDiasPrevColab: TSpinEdit;
    LblDiasPrevistos: TLabel;
    ImageList1: TImageList;
    MmObservacao: TMemo;
    LblObservacao: TLabel;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CmbBxSelecaoColaboradorSelect(Sender: TObject);
    procedure BtnEditarClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure BtnSalvarAlteracoesClick(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);

  private

    CargaColaboradores : TList<TColaborador>;

    ColaboradorSelecionado : TColaborador;
    EstadoEdicao : TEstadoEdicao;

    procedure ExecutarCargaDeDados;
    procedure ResetarTodosOsCampos;

    procedure IniciarCenarioEdicao;
    procedure IniciarCenarioNovoCadastro;

    procedure PreencherComboBoxComColaboradores(var combobox: TComboBox);
    procedure AtualizarDescricaoVisualizacao(const acao, projeto: String);

    procedure RecarregarColaboradorEmCenario;
    procedure CarregarColaboradorEmCenarioTela(var colaborador: TColaborador);

    procedure CenarioPadrao;

  public
    destructor Destroy; override;

  end;

var
  FrmGerenciadorColaborador: TFrmGerenciadorColaborador;

implementation

{$R *.dfm}

{ EVENTOS }

procedure TFrmGerenciadorColaborador.FormShow(Sender: TObject);
begin
  CenarioPadrao;
  PreencherComboBoxComColaboradores(CmbBxSelecaoColaborador);
  TUtil.CenterForm(Self);
end;

procedure TFrmGerenciadorColaborador.ExecutarCargaDeDados;
begin
  GerenciadorColaborador.LocalizarTodos(CargaColaboradores);
end;

procedure TFrmGerenciadorColaborador.RecarregarColaboradorEmCenario;
begin
  if Assigned(ColaboradorSelecionado) and SameText(CmbBxSelecaoColaborador.Text, ColaboradorSelecionado.Login) then
  begin
    MessageDlg('Colaborador já selecionado.', TMsgDlgType.mtWarning, [mbOk], 0);
    Exit;
  end;

  for var colaborador in CargaColaboradores do
    if SameText(colaborador.Login, CmbBxSelecaoColaborador.Text) then
    begin
      ColaboradorSelecionado := colaborador;
      CarregarColaboradorEmCenarioTela(ColaboradorSelecionado);
      Exit;
    end;
end;

procedure TFrmGerenciadorColaborador.ResetarTodosOsCampos;
begin
  { RESETANDO VALORES NA TELA }
  CmbBxSelecaoColaborador.Text := CmbBxSelecaoColaborador.Items[0];
  LblLoginColab.Text     := '';
  LblDsColab.Text        := '';
  MmObservacao.Text      := '';
  SpnDiasPrevColab.Value := 15;
end;


procedure TFrmGerenciadorColaborador.BtnCancelarClick(Sender: TObject);
begin
  if EstadoEdicao <> Preview then
  begin
    CenarioPadrao;
  end;
end;


procedure TFrmGerenciadorColaborador.BtnEditarClick(Sender: TObject);
begin
  if EstadoEdicao <> TEstadoEdicao.Preview then
  begin
    MessageDlg('O cenário atual já está em modo de edição.', TMsgDlgType.mtWarning, [mbOk], 0);
    Exit;
  end;

  if Not String.IsNullOrWhiteSpace(CmbBxSelecaoColaborador.Text) then
  begin
    AtualizarDescricaoVisualizacao('Editando',  CmbBxSelecaoColaborador.Text);
    IniciarCenarioEdicao;
  end;
end;

procedure TFrmGerenciadorColaborador.BtnExcluirClick(Sender: TObject);
begin
  if Assigned(ColaboradorSelecionado) and (EstadoEdicao <> EditandoNovo) then
  begin
    case TGlobalVisualMiscs.ConfirmarSimples('Realmente deseja excluir este colaborador?') of
        mrYes:
        begin
          GerenciadorColaborador.ExcluirColaboradorPorId(ColaboradorSelecionado.Id);
          CenarioPadrao;
        end;
    end;
  end;
end;

procedure TFrmGerenciadorColaborador.BtnNovoClick(Sender: TObject);
begin
  if EstadoEdicao = Preview then
  begin
    AtualizarDescricaoVisualizacao('Criando',  'Novo');
    IniciarCenarioNovoCadastro;
  end;
end;

procedure TFrmGerenciadorColaborador.BtnSairClick(Sender: TObject);
begin
  ModalResult := mrOk;
  CloseModal;
end;

procedure TFrmGerenciadorColaborador.BtnSalvarAlteracoesClick(Sender: TObject);
var
  EdicaoColaborador : TDictionary<String, Variant>;
  NovoColaborador : TColaborador;
begin

  if SpnDiasPrevColab.Value > GerenciadorConfiguracao.VlMaximoDeDiasAComprir then
  begin
    TFrmValidacaoSimples.MostrarValidacao(
      'Valor não permitido!',
      Format('O valor de dias à comprimir não pode ser maior que %d.', [GerenciadorConfiguracao.VlMaximoDeDiasAComprir]),
      'É possível alterar o valor máximo de dias à comprimir em Inicio >> Opções.');
    Exit;
  end;

  EdicaoColaborador := TDictionary<String, Variant>.Create;
  try
    with EdicaoColaborador do
    begin
      Add(TColaborador.clDsColaborador, LblDsColab.Text);
      Add(TColaborador.clLogin, LblLoginColab.Text);
      Add(TColaborador.clObservacao, MmObservacao.Lines.Text);
      Add(TColaborador.clTotalDiasPrevistos, SpnDiasPrevColab.Value);
    end;

    if EstadoEdicao = TEstadoEdicao.EditandoExistente then
    begin
      GerenciadorColaborador.AtualizarColaboradorPorId(ColaboradorSelecionado.Id, EdicaoColaborador);
      MessageDlg(
          Format('Colaborador "%s" atualizado com sucesso!', [ EdicaoColaborador[TColaborador.clLogin] ]),
          TMsgDlgType.mtInformation, [mbOk], 0);
      CenarioPadrao;
    end
    else if EstadoEdicao = TEstadoEdicao.EditandoNovo then
    begin

      NovoColaborador := TColaborador.Create;
      NovoColaborador.Login              := EdicaoColaborador[TColaborador.clLogin];
      NovoColaborador.Descricao          := EdicaoColaborador[TColaborador.clDsColaborador];
      NovoColaborador.Observacao         := EdicaoColaborador[TColaborador.clObservacao];
      NovoColaborador.TotalDiasPrevistos := EdicaoColaborador[TColaborador.clTotalDiasPrevistos];
      NovoColaborador.DataCadastro       := Now;
      NovoColaborador.StAtivo            := True;

      if GerenciadorColaborador.CriarColaborador(NovoColaborador) then
      begin
        MessageDlg(
          Format('Colaborador "%s" cadastrado com sucesso!', [NovoColaborador.Login]),
          TMsgDlgType.mtInformation, [mbOk], 0);
        CenarioPadrao;
      end;
    end;

  finally
    if Assigned(NovoColaborador) then
      NovoColaborador.Free;
  end;
end;

procedure TFrmGerenciadorColaborador.CarregarColaboradorEmCenarioTela(var colaborador: TColaborador);
begin
 if Assigned(colaborador) then
 begin
   LblLoginColab.Text      := colaborador.Login;
   LblDsColab.Text         := colaborador.Descricao;
   SpnDiasPrevColab.Value  := colaborador.TotalDiasPrevistos;
   MmObservacao.Lines.Text := colaborador.Observacao;
 end;
end;

procedure TFrmGerenciadorColaborador.PreencherComboBoxComColaboradores(var combobox: TComboBox);
begin
  combobox.Items.Clear;
  for var colaborador in CargaColaboradores do
  begin
    combobox.Items.Add(colaborador.Login);
  end;
end;

procedure TFrmGerenciadorColaborador.FormCreate(Sender: TObject);
begin
  Constraints.MinHeight := ClientHeight;
  Constraints.MinWidth := ClientWidth;
  TGlobalVisualMiscs.CustomPrepareForm(Self);
end;


procedure TFrmGerenciadorColaborador.IniciarCenarioEdicao;
begin

  EstadoEdicao := TEstadoEdicao.EditandoExistente;

  PnVisualizacao.Enabled          := True;
  PnEdicaoColab.Enabled           := False;
  CmbBxSelecaoColaborador.Enabled := False;

  BtnNovo.Enabled             := False;
  BtnCancelar.Visible         := True;
  BtnSalvarAlteracoes.Visible := True;

end;

procedure TFrmGerenciadorColaborador.IniciarCenarioNovoCadastro;
begin
  if Assigned(ColaboradorSelecionado) then
  begin
    ColaboradorSelecionado.Free;
  end;

  ResetarTodosOsCampos;

  ColaboradorSelecionado := TColaborador.Create;
  EstadoEdicao := TEstadoEdicao.EditandoNovo;

  PnVisualizacao.Enabled          := True;
  PnEdicaoColab.Enabled           := False;
  CmbBxSelecaoColaborador.Enabled := False;

  BtnNovo.Enabled             := False;
  BtnCancelar.Visible         := True;
  BtnSalvarAlteracoes.Visible := True;

end;

procedure TFrmGerenciadorColaborador.CenarioPadrao;
begin

  { EXECUÇÃO DE CARGA DE DADOS }

  ExecutarCargaDeDados;

  { INICIALIZANDO ESTADOS DA TELA }

  EstadoEdicao := TEstadoEdicao.Preview;
  AtualizarDescricaoVisualizacao('', '');
  PreencherComboBoxComColaboradores(CmbBxSelecaoColaborador);
  ResetarTodosOsCampos;

  { HABILITANDO/DESABILITANDO COMPONENTES DE ACORDO COM O CENÁRIO }

  CmbBxSelecaoColaborador.Enabled := True;
  PnVisualizacao.Enabled          := False;
  PnEdicaoColab.Enabled           := False;

  BtnNovo.Enabled             := True;
  BtnCancelar.Visible         := False;
  BtnSalvarAlteracoes.Visible := False;


end;

procedure TFrmGerenciadorColaborador.AtualizarDescricaoVisualizacao(const acao, projeto: String);
begin
  GpBxCb.Caption := Format('%s %s', [acao, projeto]);
end;

procedure TFrmGerenciadorColaborador.CmbBxSelecaoColaboradorSelect(
  Sender: TObject);
begin
  if CmbBxSelecaoColaborador.ItemIndex <> -1 then
  begin
    RecarregarColaboradorEmCenario;
    PnEdicaoColab.Enabled := not String.IsNullOrWhiteSpace(CmbBxSelecaoColaborador.Text);
  end;
end;

destructor TFrmGerenciadorColaborador.Destroy;
begin
  if Assigned(CargaColaboradores) then
  begin
    FreeAndNil(CargaColaboradores);
  end;
  inherited;
end;

end.
