unit uPrincipal;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Login,
  FireDAC.Stan.Intf,
  FireDAC.Comp.UI,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.FMXUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.PGDef,
  FireDAC.Phys.PG,
  FireDAC.DApt,
  FireDAC.Moni.Base,
  FireDAC.Moni.RemoteClient,
  System.Rtti,
  Vcl.Graphics,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.TitleBarCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  FireDAC.VCLUI.Wait,
  Vcl.Grids,
  Vcl.DBGrids,Windows,
  Math,
  DBClient,
  D16Grids,
  System.JSON,
  System.Generics.Collections,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.Menus,
  Vcl.Tabs,
  uRepo,
  D16Utils,
  System.ImageList,
  Vcl.ImgList,
  uPrinVisualGrid,
  uCadastroFerias,
  uCadastroProjeto,
  uSelecaoProjeto,
  uControleProjeto,
  uControleColaborador,
  uControleConfiguracao,
  uVisualMiscs,
  uGerenciadores,
  uCargaStatus,
  uGerenciadorColaborador,
  LoginDialog,
  uOpcoes,
  D16Custom;

type

  TFormPrincipal = class(TForm)
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    DcGridPrincipal: TDCGrid;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    MnExcluir: TMenuItem;
    LblLegendaStatusAberto: TLabel;
    LblLegendaStatusFinalizado: TLabel;
    GroupBox1: TGroupBox;
    LblLegendaStatusAndamento: TLabel;
    MnAdicionar: TMenuItem;
    MnAdaptarGrid: TMenuItem;
    MnVincularProjeto: TMenuItem;
    MnPlanejarFerias: TMenuItem;
    N1: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    BtnEditarFeriasColaborador: TSpeedButton;
    BtnAdicionarColaborador: TSpeedButton;
    BtnAdaptarGrid: TSpeedButton;
    BtnGerenciarProjetos: TSpeedButton;
    BtnOpcoes: TSpeedButton;

    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DcGridPrincipalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure BtnGerenciarProjetosClick(Sender: TObject);
    procedure BtnAdicionarColaboradorClick(Sender: TObject);
    procedure BtnOpcoesClick(Sender: TObject);

    private
      MainGridInterceptor : TMainGridInterceptor;

      procedure AtualizarGrid;
      procedure ConfigurarAcoes;
      procedure AcaoExcluirColaboradorSelecionado(sender: TObject);
      procedure AcaoVincularProjetoAoColaborador(sender: TObject);
      procedure AcaoPlanejarFeriasDeColaborador(sender: TObject);
      procedure AcaoAdicionarNovoColaborador(sender: TObject);
      procedure AcaoAdaptarGrid(sender: TObject);

      procedure ConfigurarStatusLegendas;

    { Private declarations }

  public
    function GetLoginSelecionado(): String;
    function GetIndiceColuna(nomeColuna: String): Integer;
    function GetValorCelula(idcCol: Integer; idcRow: Integer): TJSONArray;

    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

procedure TFormPrincipal.AcaoAdicionarNovoColaborador(sender: TObject);
var
  FrmGerenciadorColaborador : TFrmGerenciadorColaborador;
begin
  try
    FrmGerenciadorColaborador := TFrmGerenciadorColaborador.Create(Self);
    FrmGerenciadorColaborador.ShowModal;
  finally
    FrmGerenciadorColaborador.Free;
    AtualizarGrid;
    DcGridPrincipal.FixedRows := 1;
  end;
end;

procedure TFormPrincipal.AcaoExcluirColaboradorSelecionado(sender: TObject);
var
  LoginSelecionado : String;
  Colaborador : TColaborador;
  Mensagem : String;
begin
  try
    LoginSelecionado := GetLoginSelecionado;
    if Not String.IsNullOrWhiteSpace(LoginSelecionado) then
      if GerenciadorColaborador.LocalizarPorLogin(LoginSelecionado, Colaborador) then
      begin
        Mensagem := Format('Confirmar exclusão de %s (%s) ?', [Colaborador.Login, Colaborador.Descricao]);
        case TGlobalVisualMiscs.ConfirmarSimples(Mensagem) of
          mrYes:
          begin
            GerenciadorColaborador.ExcluirColaboradorPorId(Colaborador.Id);
            MessageDlg('Colaborador removido com sucesso!', TMsgDlgType.mtInformation, [mbOK], 0);
            AtualizarGrid;
          end;
        end;
      end;
  finally
    Colaborador.Free;
  end;
end;


procedure TFormPrincipal.AcaoAdaptarGrid(sender: TObject);
begin
  DcGridPrincipal.ResizeColumnsToGridWidth;
  DcGridPrincipal.ColWidths[0] := 25;
  AtualizarGrid;
end;

procedure TFormPrincipal.AcaoPlanejarFeriasDeColaborador(sender: TObject);
var
  FrmCadastroFerias : TFrmCadastroFerias;
  LoginSelecionado : String;
  Colaborador : TColaborador;
begin
  try
    LoginSelecionado := GetLoginSelecionado;

    if GerenciadorColaborador.LocalizarPorLogin(LoginSelecionado, Colaborador) then
    begin
      FrmCadastroFerias := TFrmCadastroFerias.Create(Self, Colaborador);
      FrmCadastroFerias.ShowModal;
    end;
  finally
    FrmCadastroFerias.Free;
    AtualizarGrid;
  end;
end;

procedure TFormPrincipal.AcaoVincularProjetoAoColaborador(sender: TObject);
var
  LoginSelecionado : String;
  Colaborador : TColaborador;
  FrmSelecaoProjeto : TFrmSelecaoProjeto;
begin
  try
    if DcGridPrincipal.Selection.Top > 0 then
    begin
      LoginSelecionado := GetLoginSelecionado;
      if GerenciadorColaborador.LocalizarPorLogin(LoginSelecionado, Colaborador) then
      begin
        FrmSelecaoProjeto := TFrmSelecaoProjeto.Create(Colaborador, Self);
        FrmSelecaoProjeto.ShowModal;
      end;
    end;
  finally
    if Assigned(FrmSelecaoProjeto) then
      FrmSelecaoProjeto.Free;

    if Assigned(Colaborador) then
      Colaborador.Free;

    AtualizarGrid;
  end;
end;

function TFormPrincipal.GetLoginSelecionado(): String;
var
  IndiceColunaLogin : Integer;
  ComJSONObject : TJSONObject;
begin
  IndiceColunaLogin := GetIndiceColuna('Usuário');
  if IndiceColunaLogin <> -1 then
  begin
    ComJSONObject := GetValorCelula(IndiceColunaLogin, DcGridPrincipal.Row).Get(0) as TJSONObject;
    Result := ComJSONObject.GetValue<String>(TKeyDict.vlTextoKey);
    ComJSONObject.Free;
  end;
end;

function TFormPrincipal.GetValorCelula(idcCol: Integer; idcRow: Integer): TJSONArray;
begin
  Result := TJSONObject.ParseJSONValue(DcGridPrincipal.Cells[idcCol, idcRow]) as TJSONArray;
end;

procedure TFormPrincipal.BtnGerenciarProjetosClick(Sender: TObject);
var
  FrmCadastroProjeto : TFrmCadastroProjeto;
begin
  try
    FrmCadastroProjeto := TFrmCadastroProjeto.Create(Self);
    FrmCadastroProjeto.ShowModal;
  finally
    FrmCadastroProjeto.Free;
    AtualizarGrid;
  end;
end;

procedure TFormPrincipal.BtnOpcoesClick(Sender: TObject);
var
  FrmOpcoes : TFrmOpcoes;
begin
  FrmOpcoes := TFrmOpcoes.Create(Self);
  try
    FrmOpcoes.ShowModal;
  finally
    FreeAndNil(FrmOpcoes);
    AtualizarGrid;
  end;

end;

function TFormPrincipal.GetIndiceColuna(nomeColuna: String): Integer;
var
  ComJSONArray : TJSONArray;
  JSONObject : TJSONObject;
  I : Integer;
begin
  Result := -1;
  for I := 0 to DcGridPrincipal.RowCount - 1 do
  begin
    ComJSONArray := TJSONObject.ParseJSONValue(DcGridPrincipal.Cells[I, 0]) as TJSONArray;
    JSONObject := ComJSONArray.Get(0) as TJSONObject;
    if JSONObject.GetValue<String>(TKeyDict.vlTextoKey) = nomeColuna then
    begin
      ComJSONArray.Free;
      Exit(I);
    end;
  end;
end;

procedure TFormPrincipal.DcGridPrincipalMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Integer;
begin
  if Button = TMouseButton.mbRight then
  begin
    DcGridPrincipal.MouseToCell(X, Y, ACol, ARow);
    DcGridPrincipal.Row := ARow;
  end;
end;

procedure TFormPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
var
  LoginDialog : TLoginForm;
begin
  try
    LoginDialog := TLoginForm.Create(Self);
    TUtil.CenterForm(LoginDialog);
    LoginDialog.ShowModal;
    if not LoginDialog.Logado then
    begin
      Close;
      Application.Terminate;
    end;
  finally
    LoginDialog.Free;
  end;

  WindowState := TWindowState.wsMaximized;
  DcGridPrincipal.CustomDrawOptions.TitleColumnHeight := 40;
  DcGridPrincipal.CustomDrawOptions.DrawColumnLine := False;
  DcGridPrincipal.CustomDrawOptions.BadgeLeftPadding := 40;
  DcGridPrincipal.CustomDrawOptions.RowLeftMargin := 10;
  DcGridPrincipal.CustomDrawOptions.RowTopMargin := 5;
  DcGridPrincipal.CustomDrawOptions.BadgeTopPadding := 7;
  DcGridPrincipal.CustomDrawOptions.SelectionFillColor := clBlack;

  ConfigurarAcoes;

  StatusBar1.Panels[0].Text := Format('%s em %s/%s', [FdConnection.Params.UserName,
    FdConnection.Params.Values['Server'], FdConnection.Params.Database]);
end;

procedure TFormPrincipal.FormResize(Sender: TObject);
begin
  DcGridPrincipal.ResizeColumnsToGridWidth;
  DcGridPrincipal.ColWidths[0] := 25;
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
var
  Row, Col : Integer;
  FDQuery: TFDQuery;
begin
  TUtil.CenterForm(FormPrincipal);
  MainGridInterceptor := TMainGridInterceptor.Create;
  DcGridPrincipal.DataSetInterceptor := MainGridInterceptor;
  AtualizarGrid;
end;

procedure TFormPrincipal.AtualizarGrid;
var
  FDQuery: TFDQuery;
  GridSQL : TStringList;
  FrmStatus : TCarregamentoStatus;
  LasSelectedIndex : Integer;
begin
  LasSelectedIndex := IfThen(DcGridPrincipal.Row <= -1, 0, DcGridPrincipal.Row);

  FrmStatus := TCarregamentoStatus.Create(Self);
  FrmStatus.Show;
  try

    FrmStatus.Status('Aguarde');
    FrmStatus.Mensagem('Carregando informações de projeto e períodos...');
    MainGridInterceptor.CarregarDadosLocais;

    GridSQL := TStringList.Create;
    with GridSQL do
    begin
      BeginUpdate;
      Add('SELECT');
      Add('  ''●'' as icone,');
      Add('  C.login,');
      Add('  C.dscolaborador,');
      Add('  C.observacao,');
      Add('  C.totaldiasprevistos,');
      Add('  COALESCE(SUM(DISTINCT EXTRACT(EPOCH FROM (dtfinal - dtinicio)) / 86400), ''0'')::INTEGER AS totaldiasregistrados,');
      Add('  ARRAY_AGG(DISTINCT PE.idcbperiodo) AS idcbperiodos,');
      Add('  ARRAY_AGG(DISTINCT P.idprojeto) AS projetos');
      Add('FROM controleferias.colaborador C');
      Add('LEFT JOIN controleferias.cbperiodos PE');
      Add('ON (C.idcolaborador = PE.idcolaborador)');
      Add('LEFT JOIN controleferias.cbproj CB ');
      Add('ON (C.idcolaborador = CB.idcolaborador)');
      Add('LEFT JOIN controleferias.projeto P');
      Add('ON (P.idprojeto = CB.idprojeto)');
      Add('WHERE');
      Add('  C.stativo = true');
      Add('GROUP BY');
      Add('  C.idcolaborador,');
      Add('  C.login,');
      Add('  C.dscolaborador,');
      Add('  C.observacao');
      Add('ORDER BY');
      Add('  C.login DESC;');
      EndUpdate;
    end;

    TQueryManager.Instancia
      .CreateQuery(GridSQL.Text, FDConnection, FDQuery, nil, False);

    FrmStatus.Mensagem('Carregando quadro de funcinários...');
    if not FDQuery.IsEmpty then
    begin
      DcGridPrincipal.DataSet := FDQuery;
    end
    else
    begin
      DcGridPrincipal.ClearTableCells;
    end;

    ConfigurarStatusLegendas;

    DcGridPrincipal.ColWidths[0] := 25; {Reajustar tamanho da coluna com "icone"}

    { selecionar ultimo selecionado antes do update na grid }
    if DcGridPrincipal.RowCount >= LasSelectedIndex then
    begin
      DcGridPrincipal.Row := LasSelectedIndex;
      DcGridPrincipal.Update;
    end;

    FrmStatus.Mensagem('Ok.');

  finally
    FrmStatus.Close;
    FrmStatus.Free;
    FDQuery.Free;
    GridSQL.Free;
  end;

end;

procedure TFormPrincipal.BtnAdicionarColaboradorClick(Sender: TObject);
var
  FrmGerenciadorColaborador : TFrmGerenciadorColaborador;
begin
  try
    FrmGerenciadorColaborador := TFrmGerenciadorColaborador.Create(Self);
    FrmGerenciadorColaborador.ShowModal;
  finally
    FrmGerenciadorColaborador.Free;
    AtualizarGrid;
  end;
end;

procedure TFormPrincipal.ConfigurarAcoes;
begin
  { Exclusão }
  MnExcluir.OnClick := AcaoExcluirColaboradorSelecionado;

  {Inclusão}
  {BtnAdicionarColaborador.OnClick := AcaoAdicionarNovoColaborador;}
  MnAdicionar.OnClick := AcaoAdicionarNovoColaborador;

  {Outros}
  BtnAdaptarGrid.OnClick := AcaoAdaptarGrid;
  MnAdaptarGrid.OnClick := AcaoAdaptarGrid;

  {Projetos}
  MnVincularProjeto.OnClick := AcaoVincularProjetoAoColaborador;

  {edição}
  BtnEditarFeriasColaborador.OnClick := AcaoPlanejarFeriasDeColaborador;
  MnPlanejarFerias.OnClick := AcaoPlanejarFeriasDeColaborador;
end;

procedure TFormPrincipal.ConfigurarStatusLegendas;
begin
  { Carregar cores do banco nas legendas }
  LblLegendaStatusAberto.Font.Color     := TUtil.HexToColor(GerenciadorConfiguracao.CorStatusAberto);
  LblLegendaStatusAndamento.Font.Color  := TUtil.HexToColor(GerenciadorConfiguracao.CorStatusAndamento);
  LblLegendaStatusFinalizado.Font.Color := TUtil.HexToColor(GerenciadorConfiguracao.CorStatusFinalizado);
end;

end.
