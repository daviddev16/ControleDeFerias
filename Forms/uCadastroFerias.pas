unit uCadastroFerias;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Generics.Collections,
  System.Variants,
  System.Classes,
  System.DateUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  D16Grids,
  Vcl.StdCtrls,
  FireDAC.Comp.Client,
  uGerenciadores,
  uRepo,
  Data.DB,
  System.JSON,
  Vcl.WinXCalendars,
  Vcl.Samples.Calendar,
  Vcl.Buttons,
  D16Utils,
  uValidacaoSimples,
  uVisualMiscs,
  uControleColaborador,
  uInformativo,
  uSelecaoPeriodos,
  uCargaStatus,
  uFeriasVisualGrid,
  System.ImageList,
  Vcl.ImgList;

type

  TFrmCadastroFerias = class(TForm)
    GroupBox1: TGroupBox;
    DcGridPeriodos: TDCGrid;
    DcGridConflitos: TDCGrid;
    GroupBox2: TGroupBox;
    ComboBox1: TComboBox;
    BtnFinalizarEdicao: TSpeedButton;
    TabSheet1: TTabSheet;
    PgCtTabMenu: TPageControl;
    BtnExcluir: TSpeedButton;
    ImageList1: TImageList;
    BtnAdicionar: TSpeedButton;
    BtnComparar: TSpeedButton;
    BtnEntenderRelFerias: TSpeedButton;
    LblTituloRelFerias: TLabel;
    BtnLimparPeriodos: TSpeedButton;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure BtnFinalizarEdicaoClick(Sender: TObject);
    procedure BtnAdicionarClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure BtnCompararClick(Sender: TObject);
    procedure BtnLimparPeriodosClick(Sender: TObject);
    procedure BtnEntenderRelFeriasClick(Sender: TObject);

  private
    ColaboradorSelecionado : TColaborador;
    GridPeriodoInterceptor : TFeriasPeriodosInterceptor;
    GridConflitosInterceptor : TFeriasConflitosInterceptor;

    procedure AtualizarGrid;
    procedure ConfigurarPadroesEmGrid(var dcGrid: TDCGrid);

    procedure VerificarConflitos; overload;
    procedure VerificarConflitos(var frmStatus: TCarregamentoStatus); overload;
    
    function GetFiltroConflito(): TFiltroConflitos;

    function GetPeriodoSelecionado(): String;
    function GetIndiceColuna(nomeColuna: String): Integer;
    function GetValorCelula(idcCol: Integer; idcRow: Integer): TJSONArray;

  public
    constructor Create(owner: TComponent; var Colaborador: TColaborador);
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

constructor TFrmCadastroFerias.Create(owner: TComponent; var Colaborador: TColaborador);
begin
  Self.ColaboradorSelecionado := Colaborador;
  inherited Create(owner);
end;

procedure TFrmCadastroFerias.BtnAdicionarClick(Sender: TObject);
var
  FrmSelecaoPerido : TFrmSelecaoPeriodo;
  DatasComConflito : TList<String>;
begin
  FrmSelecaoPerido := TFrmSelecaoPeriodo.Create(Self);
  try
    FrmSelecaoPerido.ShowModal;
    if FrmSelecaoPerido.ModalResult = mrOk then
    begin

      { !! Um período não pode colapsar com os demais períodos do colaborador !! }
      if GerenciadorColaborador.VerificarAutoColapso(FrmSelecaoPerido.DataInicio,
          FrmSelecaoPerido.DataFinal, ColaboradorSelecionado.Id, DatasComConflito) then
      begin

       TFrmValidacaoSimples.MostrarValidacao
       (
        'Período inválido.',
        Format('O período informado converge com: %s. ', [String.Join(', ', DatasComConflito.ToArray) ]),
        'Informe um período que não colida com os já existentes do colaborador.'
       );
       Exit;

      end;

      GerenciadorColaborador.
        AdicionarPeriodoFeriasPorId(FrmSelecaoPerido.DataInicio,
          FrmSelecaoPerido.DataFinal, Colaboradorselecionado.Id);

      AtualizarGrid;

    end;
  finally
    FrmSelecaoPerido.Free;
  end;
end;

function TFrmCadastroFerias.GetIndiceColuna(nomeColuna: String): Integer;
var
  ComJSONArray : TJSONArray;
  JSONObject : TJSONObject;
  I : Integer;
begin
  Result := -1;
  for I := 0 to DcGridPeriodos.RowCount - 1 do
  begin
    ComJSONArray := TJSONObject.ParseJSONValue(DcGridPeriodos.Cells[I, 0]) as TJSONArray;
    JSONObject := ComJSONArray.Get(0) as TJSONObject;
    if JSONObject.GetValue<String>(TKeyDict.vlTextoKey) = nomeColuna then
    begin
      Exit(I);
    end;
  end;
  ComJSONArray.Free;
end;

function TFrmCadastroFerias.GetFiltroConflito(): TFiltroConflitos;
begin
  if ComboBox1.Text = 'Mostrar Todos' then
    Exit(TFiltroConflitos.Todos);
  if ComboBox1.Text = 'Mostrar conflitos' then
    Exit(TFiltroConflitos.ComConflitos);
  if ComboBox1.Text = 'Mostrar Sem conflitos' then
    Exit(TFiltroConflitos.SemConflito);
end;

procedure TFrmCadastroFerias.FormResize(Sender: TObject);
begin
  DcGridConflitos.ResizeColumnsToGridWidth;
  DcGridPeriodos.ResizeColumnsToGridWidth;
end;

procedure TFrmCadastroFerias.BtnLimparPeriodosClick(Sender: TObject);
var
  Mensagem : String;
begin
  Mensagem := Format('Confirmar exclusão de TODOS os períodos para %s (%s) ?',
    [ColaboradorSelecionado.Login, ColaboradorSelecionado.Descricao]);
  case TGlobalVisualMiscs.ConfirmarSimples(Mensagem) of
    mrYes:
    begin
      GerenciadorColaborador.LimparTodosPeriodosPorId(ColaboradorSelecionado.Id);
      MessageDlg('Todos os períodos foram removidos!', TMsgDlgType.mtInformation, [mbOK], 0);
      AtualizarGrid;
    end;
  end;
end;

procedure TFrmCadastroFerias.BtnEntenderRelFeriasClick(Sender: TObject);
var
  FrmInformativoRelFerias : TFrmInformativo;
begin
  if WindowState = TWindowState.wsMaximized then
  begin
    MessageDlg('Não é possível mostrar o informativo em tela cheia.', 
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;
  try
    FrmInformativoRelFerias := TFrmInformativo.MostrarInformativoRelacaoFerias(Self);
  finally
    FrmInformativoRelFerias.Free;
  end;
end;

procedure TFrmCadastroFerias.BtnExcluirClick(Sender: TObject);
var
  IdCbPeriodo : Integer;
  IdColaborador : Integer;
begin

  if String.IsNullOrWhiteSpace(GetPeriodoSelecionado) then
  begin
    MessageDlg('Selecione um período antes.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;

  IdCbPeriodo := StrToInt(GetPeriodoSelecionado);
  IdColaborador := ColaboradorSelecionado.Id;
  if IdCbPeriodo <> -1 then
  begin
    GerenciadorColaborador.RemoverPeriodoFeriasPorId(IdCbPeriodo, IdColaborador);
    MessageDlg('Período removido com sucesso!', TMsgDlgType.mtInformation, [mbOK], 0);
    AtualizarGrid;
  end;
end;

procedure TFrmCadastroFerias.VerificarConflitos(var frmStatus: TCarregamentoStatus);
var
  IdCbPeriodo : Integer;
begin

  if String.IsNullOrWhiteSpace(GetPeriodoSelecionado) then
  begin
    MessageDlg('Selecione um período antes.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;

  frmStatus.Show;
  IdCbPeriodo := StrToInt(GetPeriodoSelecionado);

  for var periodo in GridPeriodoInterceptor.CargaLocalCbPeriodos do
  begin
    if periodo.IdCbPeriodo = IdCbPeriodo then
    begin
      frmStatus.Status('Verificando');
      frmStatus.Mensagem('Cálculando conflitos do período...');
      GerenciadorColaborador.VerificarConflitosDePeriodo(periodo.DataInicio, periodo.DataFinal,
        DcGridConflitos, GetFiltroConflito, ColaboradorSelecionado.Id);
        DcGridConflitos.Unselect;
      LblTituloRelFerias.Caption := Format('Analisando período: %s à %s',
        [FormatDateTime('dd/mm/yyyy', periodo.DataInicio), FormatDateTime('dd/mm/yyyy', periodo.DataFinal)]);
      break;
    end;
  end;
end;

procedure TFrmCadastroFerias.AtualizarGrid;
var
  FDQuery: TFDQuery;
  FrmStatus : TCarregamentoStatus;
  Parameters : TDictionary<String, Variant>;
  GridSQL : TStringList;
  Text : String;
begin

  GridSQL := TStringList.Create;
  Parameters := TDictionary<String, Variant>.Create;
  FrmStatus := TCarregamentoStatus.Create(Self);
  FrmStatus.Show;
  FrmStatus.Status('Aguarde.');
  FrmStatus.Mensagem('Carregando períodos e conflitos...');

  try
    DcGridPeriodos.DataSetInterceptor := GridPeriodoInterceptor;
    GridPeriodoInterceptor.CarregarDadosLocais(ColaboradorSelecionado);

    with GridSQL do
    begin
      BeginUpdate;
      Add('SELECT');
      Add('idcbperiodo as "idcbp",');
      Add('idcbperiodo as "idcbperiodo"');
      Add('FROM');
      Add(' controleferias.cbperiodos');
      Add('WHERE');
      Add(' idcolaborador = :paramIdColaborador;');
      EndUpdate;
    end;

    with Parameters do
    begin
      Add('paramIdColaborador', ColaboradorSelecionado.Id);
    end;

    TQueryManager.Instancia
      .CreateQuery(GridSQL.Text, FDConnection, FDQuery, Parameters, False);

    if FDQuery.RecordCount > 0 then
    begin
      DcGridPeriodos.DataSet := FDQuery;
      VerificarConflitos(FrmStatus);
    end
    else
    begin
      DcGridConflitos.ClearTableCells;
      DcGridPeriodos.ClearTableCells;
    end;

    DcGridPeriodos.ColWidths[0] := 0;
    DcGridPeriodos.ResizeColumnsToGridWidth;

  finally
    FDQuery.Free;
    GridSQL.Free;
    Parameters.Free;
    FrmStatus.Mensagem('Finalizado.');
    FrmStatus.Close;
    FrmStatus.Free;
  end;

end;

procedure TFrmCadastroFerias.ConfigurarPadroesEmGrid(var dcGrid: TDCGrid);
begin
  dcGrid.CustomDrawOptions.TitleColumnHeight := 40;
  dcGrid.CustomDrawOptions.DrawColumnLine := False;
  dcGrid.CustomDrawOptions.BadgeLeftPadding := 40;
  dcGrid.CustomDrawOptions.RowLeftMargin := 7;
  dcGrid.CustomDrawOptions.RowTopMargin := 7;
  dcGrid.CustomDrawOptions.BadgeTopPadding := 5;
  dcGrid.CustomDrawOptions.SelectionFillColor := clBlack;
end;

procedure TFrmCadastroFerias.FormShow(Sender: TObject);
begin

  GridPeriodoInterceptor := TFeriasPeriodosInterceptor.Create;
  DcGridPeriodos.DataSetInterceptor := GridPeriodoInterceptor;

  GridConflitosInterceptor := TFeriasConflitosInterceptor.Create;
  DcGridConflitos.DataSetInterceptor := GridConflitosInterceptor;

  TUtil.CenterForm(Self);
  LblTituloRelFerias.Caption := 'Nenum período sendo analisado.';
  ConfigurarPadroesEmGrid(DcGridPeriodos);
  ConfigurarPadroesEmGrid(DcGridConflitos);
  AtualizarGrid;

end;

procedure TFrmCadastroFerias.FormCreate(Sender: TObject);
begin
  Constraints.MinHeight := ClientHeight;
  Constraints.MinWidth := ClientWidth;

  Caption := Format('Edição de Férias (%s)', [ColaboradorSelecionado.Login]);
end;

procedure TFrmCadastroFerias.VerificarConflitos;
var
  FrmStatus : TCarregamentoStatus;
begin
  FrmStatus := TCarregamentoStatus.Create(Self);
  try
    VerificarConflitos(FrmStatus);
    FrmStatus.Mensagem('Ok.');
  finally
    FrmStatus.Free;
  end;
end;

procedure TFrmCadastroFerias.BtnCompararClick(Sender: TObject);
begin
  VerificarConflitos;
end;

procedure TFrmCadastroFerias.BtnFinalizarEdicaoClick(Sender: TObject);
begin
  ModalResult := mrOk;
  CloseModal;
end;

procedure TFrmCadastroFerias.ComboBox1Change(Sender: TObject);
begin
  VerificarConflitos;
end;

function TFrmCadastroFerias.GetPeriodoSelecionado(): String;
begin
  Result := DcGridPeriodos.Cells[0, DcGridPeriodos.Row];
end;

function TFrmCadastroFerias.GetValorCelula(idcCol: Integer;
                                           idcRow: Integer): TJSONArray;
begin
  Result := TJSONObject.ParseJSONValue(
    DcGridPeriodos.Cells[idcCol, idcRow]) as TJSONArray;
end;

destructor TFrmCadastroFerias.Destroy;
begin
  inherited;
end;

end.
