unit uCadastroProjeto;

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
  Vcl.Imaging.pngimage,
  Vcl.Mask,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  System.ImageList,
  Vcl.ImgList,
  uVisualMiscs;

type

  TFrmCadastroProjeto = class(TForm)
    ClBxFundo: TColorListBox;
    CmBxFundo: TComboBox;
    DCLabelPreview1: TDCLabelPreview;
    LblTonalidadeFundo: TLabel;
    GroupBox1: TGroupBox;
    PnFundo: TPanel;
    PnTexto: TPanel;
    LblTonalidadeTexto: TLabel;
    ClBxTexto: TColorListBox;
    CmBxTexto: TComboBox;
    GpBxProj: TGroupBox;
    LblNmProj: TLabeledEdit;
    BtnSair: TButton;
    BtnCorAleatoria: TSpeedButton;
    LblDsProj: TLabeledEdit;
    Panel1: TPanel;
    ImageList1: TImageList;
    BtnNovo: TSpeedButton;
    CmbBxSelecaoProj: TComboBox;
    Shape1: TShape;
    Label1: TLabel;
    Shape2: TShape;
    BtnExcluir: TSpeedButton;
    BtnSalvarAlteracoes: TButton;
    PnVisualizacao: TPanel;
    BtnEditar: TSpeedButton;
    PnEdicaoProj: TPanel;
    BtnCancelar: TButton;

    procedure CmBxChange(Sender: TObject);
    procedure ClBxFundoDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LblNmProjChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnCorAleatoriaClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure CmbBxSelecaoProjSelect(Sender: TObject);
    procedure BtnEditarClick(Sender: TObject);
    procedure BtnSalvarAlteracoesClick(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure ClBxTextoDblClick(Sender: TObject);
    
  private

    CargaTonalidades : TList<TCorTonalidade>;
    CargaProjetos    : TList<TProjeto>;

    EstadoEdicao       : TEstadoEdicao;
    ProjetoSelecionado : TProjeto;
    CoresSelecionadas  : Array of TColor;


    procedure ExecutarCargaDeDados;
    procedure ResetarTodosOsCampos;

    procedure AtualizarDescricaoVisualizacao(const acao, projeto: String);
    procedure AtualizarCorSelecionada(var clBxSlc: TColorListBox; const indiceCorSlc: Integer);

    procedure RecarregarProjetoEmCenario;
    procedure CarregarProjetoEmCenarioTela(var projeto: TProjeto);

    procedure IniciarCenarioEdicao;
    procedure IniciarCenarioNovoCadastro;

    procedure PreencherComboBoxComProjetos(var combobox: TComboBox);
    procedure CenarioPadrao;

    procedure CarregarColorListBox(var colorListBox: TColorListBox;
                                   cmBox: TComboBox; const categoria: String);
    procedure AtualizarCorETextoPreview;
    procedure FixarPreviewCentro;
  public
    destructor Destroy; override;
  end;

var
  FrmCadastroProjeto: TFrmCadastroProjeto;

implementation

{$R *.dfm}

{ EVENTOS }

procedure TFrmCadastroProjeto.FormShow(Sender: TObject);
begin
  CenarioPadrao;
  PreencherComboBoxComProjetos(CmbBxSelecaoProj);
  TUtil.CenterForm(Self);
end;

procedure TFrmCadastroProjeto.FormCreate(Sender: TObject);
begin
  Constraints.MinHeight := ClientHeight;
  Constraints.MinWidth := ClientWidth;
  SetLength(CoresSelecionadas, 2);
  TGlobalVisualMiscs.CustomPrepareForm(Self);
end;

{
  HelpContext valores:
  0 = Cor de fundo;
  1 = Cor do texto;
}
procedure TFrmCadastroProjeto.CmBxChange(Sender: TObject);
var
  ConComboBox : TComboBox;
  ConColorListBox : TColorListBox;
begin
  ConComboBox := TComboBox(Sender);

  if ConComboBox.HelpContext = 0 then
    ConColorListBox := ClBxFundo
  else
    ConColorListBox := ClBxTexto;

  CarregarColorListBox(ConColorListBox, nil, ConComboBox.Text);
  AtualizarCorETextoPreview;
end;

procedure TFrmCadastroProjeto.CmbBxSelecaoProjSelect(Sender: TObject);
begin
  if CmbBxSelecaoProj.ItemIndex <> -1 then
  begin
    RecarregarProjetoEmCenario;
    PnEdicaoProj.Enabled := not String.IsNullOrWhiteSpace(CmbBxSelecaoProj.Text);
  end;
end;

procedure TFrmCadastroProjeto.BtnCancelarClick(Sender: TObject);
begin
  if EstadoEdicao <> Preview then
  begin
    CenarioPadrao;
  end;
end;

procedure TFrmCadastroProjeto.BtnCorAleatoriaClick(Sender: TObject);
var
  CorRandIndex : Integer;
  TemaRandNum : Integer;
  Tema1, Tema2 : String;
begin

  if EstadoEdicao = TEstadoEdicao.Preview then
    Exit;

  CorRandIndex := Random(ClBxFundo.Items.Count - 1);
  TemaRandNum := Random(2);

  if TemaRandNum <> 0 then
  begin
    Tema1 := 'Leve';
    Tema2 := 'Escuro';
  end
  else
  begin
    Tema1 := 'Escuro';
    Tema2 := 'Leve';
  end;

  if ClBxFundo.Hint <> Tema1 then
    CarregarColorListBox(ClBxFundo, CmBxFundo, Tema1);

  if ClBxTexto.Hint <> Tema2 then
    CarregarColorListBox(ClBxTexto, CmBxTexto,  Tema2);

  ClBxFundo.Selected := ClBxFundo.Colors[Min(CorRandIndex, ClBxFundo.Items.Count)];
  ClBxTexto.Selected := ClBxTexto.Colors[Min(CorRandIndex, ClBxTexto.Items.Count)];
  CoresSelecionadas[0] := ClBxFundo.Selected;
  CoresSelecionadas[1] := ClBxTexto.Selected;

  AtualizarCorETextoPreview;
end;

procedure TFrmCadastroProjeto.BtnSairClick(Sender: TObject);
begin
 ModalResult := mrOk;
 CloseModal;
end;

procedure TFrmCadastroProjeto.BtnSalvarAlteracoesClick(Sender: TObject);
var
  EdicaoProjeto : TDictionary<String, Variant>;
  NovoProjeto : TProjeto;
begin
  EdicaoProjeto := TDictionary<String, Variant>.Create;
  try
    with EdicaoProjeto do
    begin
      Add(TProjeto.cfNmProj, LblNmProj.Text);
      Add(TProjeto.cfDsProj, LblDsProj.Text);
      Add(TProjeto.cfClFundo, TUtil.ColorToHex(CoresSelecionadas[0]));
      Add(TProjeto.cfClTexto, TUtil.ColorToHex(CoresSelecionadas[1]));
    end;

    if EstadoEdicao = TEstadoEdicao.EditandoExistente then
    begin
      GerenciadorProjeto.AtualizarProjetoPorId(ProjetoSelecionado.IdProjeto, EdicaoProjeto);
      MessageDlg(
        Format('O projeto "%s" foi atualizado com sucesso!',
        [ EdicaoProjeto[TProjeto.cfNmProj] ]),
        TMsgDlgType.mtInformation,
        [mbOk], 0);
    end
    else if EstadoEdicao = TEstadoEdicao.EditandoNovo then
    begin

      NovoProjeto := TProjeto.Create;
      NovoProjeto.Nome := EdicaoProjeto[TProjeto.cfNmProj];
      NovoProjeto.Descricao := EdicaoProjeto[TProjeto.cfDsProj];
      NovoProjeto.CorFundo := EdicaoProjeto[TProjeto.cfClFundo];
      NovoProjeto.CorTexto := EdicaoProjeto[TProjeto.cfClTexto];

      GerenciadorProjeto.CadastrarProjeto(NovoProjeto);

      MessageDlg(
        Format('O projeto "%s" foi criado com sucesso!',
        [NovoProjeto.Nome]),
        TMsgDlgType.mtInformation,
        [mbOk], 0);

    end;
    CenarioPadrao;
  finally
    if Assigned(NovoProjeto) then
    begin
      NovoProjeto.Free;
    end;
  end;
end;

procedure TFrmCadastroProjeto.RecarregarProjetoEmCenario;
begin
  if Assigned(ProjetoSelecionado) and SameText(CmbBxSelecaoProj.Text, ProjetoSelecionado.Nome) then
  begin
    MessageDlg('Projeto já selecionado.', TMsgDlgType.mtWarning, [mbOk], 0);
    Exit;
  end;

  for var projeto in CargaProjetos do
    if SameText(projeto.Nome, CmbBxSelecaoProj.Text) then
    begin
      ProjetoSelecionado := projeto;
      CarregarProjetoEmCenarioTela(ProjetoSelecionado);
      Exit;
    end;
end;

procedure TFrmCadastroProjeto.BtnEditarClick(Sender: TObject);
begin
  if EstadoEdicao <> TEstadoEdicao.Preview then
  begin
    MessageDlg('O cenário atual já está em modo de edição.', TMsgDlgType.mtWarning, [mbOk], 0);
    Exit;
  end;

  if Not String.IsNullOrWhiteSpace(CmbBxSelecaoProj.Text) then
  begin
    AtualizarDescricaoVisualizacao('Editando',  CmbBxSelecaoProj.Text);
    IniciarCenarioEdicao;
  end;
end;

procedure TFrmCadastroProjeto.BtnExcluirClick(Sender: TObject);
begin
  if Assigned(ProjetoSelecionado) and (EstadoEdicao <> EditandoNovo) then
  begin
    GerenciadorProjeto.DeletarPorId(ProjetoSelecionado.IdProjeto);
    CenarioPadrao;
  end;
end;

procedure TFrmCadastroProjeto.BtnNovoClick(Sender: TObject);
begin
  if EstadoEdicao = Preview then
  begin
    AtualizarDescricaoVisualizacao('Criando',  'Novo');
    IniciarCenarioNovoCadastro;
  end;
end;

{ ATUALIZA OS VALORES NA PRÉ-VISUALIZAÇÃO }
procedure TFrmCadastroProjeto.LblNmProjChange(Sender: TObject);
begin
  DCLabelPreview1.Texto := LblNmProj.Text;
  DCLabelPreview1.Repaint;
  FixarPreviewCentro;
end;


procedure TFrmCadastroProjeto.ClBxFundoDblClick(Sender: TObject);
begin
  AtualizarCorSelecionada(ClBxFundo, 0);
end;

procedure TFrmCadastroProjeto.ClBxTextoDblClick(Sender: TObject);
begin
  AtualizarCorSelecionada(ClBxTexto, 1);
end;

procedure TFrmCadastroProjeto.FormResize(Sender: TObject);
begin
  FixarPreviewCentro;
end;

{ UTILITÁRIOS }

procedure TFrmCadastroProjeto.CarregarColorListBox(var colorListBox: TColorListBox;
                                                   cmBox: TComboBox; const categoria: String);
begin
  colorListBox.Clear;
  colorListBox.Hint := categoria;

  for var tonalidadeCor in CargaTonalidades do
    if tonalidadeCor.Categoria = categoria then
    begin
      colorListBox.Items.InsertObject(0, tonalidadeCor.Nome, TObject(tonalidadeCor.Cor))
    end;

  if (cmBox <> nil) then
  begin
    cmBox.Text := categoria;
  end;

end;

procedure TFrmCadastroProjeto.IniciarCenarioNovoCadastro;
begin
  if Assigned(ProjetoSelecionado) then
  begin
    ProjetoSelecionado.Free;
  end;

  ResetarTodosOsCampos;

  ProjetoSelecionado := TProjeto.Create;
  EstadoEdicao := TEstadoEdicao.EditandoNovo;

  PnVisualizacao.Enabled      := True;
  PnEdicaoProj.Enabled        := False;
  CmbBxSelecaoProj.Enabled    := False;

  BtnNovo.Enabled             := False;
  BtnCancelar.Visible         := True;
  BtnSalvarAlteracoes.Visible := True;

  AtualizarCorETextoPreview;
  FixarPreviewCentro;

end;

procedure TFrmCadastroProjeto.IniciarCenarioEdicao;
begin

  EstadoEdicao := TEstadoEdicao.EditandoExistente;

  PnVisualizacao.Enabled      := True;
  PnEdicaoProj.Enabled        := False;
  CmbBxSelecaoProj.Enabled    := False;

  BtnNovo.Enabled             := False;
  BtnCancelar.Visible         := True;
  BtnSalvarAlteracoes.Visible := True;

  FixarPreviewCentro;

end;

procedure TFrmCadastroProjeto.ResetarTodosOsCampos;
begin

  { RESETAR TODOS OS COLORLISTBOX }
  CarregarColorListBox(ClBxFundo, CmBxFundo, 'Leve');
  CarregarColorListBox(ClBxTexto, CmBxTexto, 'Escuro');

  { RESETANDO VALORES NA TELA }
  LblNmProj.Text        := '';
  LblDsProj.Text        := '';
  CmbBxSelecaoProj.Text := '';

  {ATUALIZAR ATRIBUTOS LABEL PREVIEW }
  DCLabelPreview1.Texto := 'Preview';
  DCLabelPreview1.CorTexto := ClBxTexto.Selected;
  DCLabelPreview1.CorFundo := ClBxFundo.Selected;
  DCLabelPreview1.Repaint;

  { SELECIONAR VALORES PADRÕES }
  ClBxTexto.Selected    := ClBxTexto.Colors[0];
  ClBxFundo.Selected    := ClBxFundo.Colors[0];
  CmbBxSelecaoProj.Text := CmbBxSelecaoProj.Items[0];

end;

procedure TFrmCadastroProjeto.CenarioPadrao;
begin

  { EXECUÇÃO DE CARGA DE DADOS }

  ExecutarCargaDeDados;

  { INICIALIZANDO ESTADOS DA TELA }

  EstadoEdicao := TEstadoEdicao.Preview;
  AtualizarDescricaoVisualizacao('', '');
  PreencherComboBoxComProjetos(CmbBxSelecaoProj);
  ResetarTodosOsCampos;

  { HABILITANDO/DESABILITANDO COMPONENTES DE ACORDO COM O CENÁRIO }

  CmbBxSelecaoProj.Enabled    := True;
  PnVisualizacao.Enabled      := False;
  PnEdicaoProj.Enabled        := False;

  BtnNovo.Enabled             := True;
  BtnCancelar.Visible         := False;
  BtnSalvarAlteracoes.Visible := False;

end;

procedure TFrmCadastroProjeto.CarregarProjetoEmCenarioTela(var projeto: TProjeto);
begin
  if Assigned(projeto) then
  begin
    CoresSelecionadas[0] := TUtil.HexToColor(projeto.CorFundo);
    CoresSelecionadas[1] := TUtil.HexToColor(projeto.CorTexto);

    DCLabelPreview1.CorFundo := CoresSelecionadas[0];
    DCLabelPreview1.CorTexto := CoresSelecionadas[1];

    DCLabelPreview1.Texto := projeto.Nome;
    LblDsProj.Text := projeto.Descricao;
    LblNmProj.Text := projeto.Nome;
  end;
end;

procedure TFrmCadastroProjeto.FixarPreviewCentro;
begin
  DCLabelPreview1.Left := (GroupBox1.Width div 2) - (DCLabelPreview1.Width div 2);
  DCLabelPreview1.Top := (GroupBox1.Height div 2) - (DCLabelPreview1.Height div 2);
end;

procedure TFrmCadastroProjeto.AtualizarCorETextoPreview;
begin
  DCLabelPreview1.CorFundo := ClBxFundo.Selected;
  DCLabelPreview1.CorTexto := ClBxTexto.Selected;
  DCLabelPreview1.Texto := LblNmProj.Text;
  DCLabelPreview1.Repaint;
end;

procedure TFrmCadastroProjeto.PreencherComboBoxComProjetos(var combobox: TComboBox);
begin
  combobox.Items.Clear;
  for var projeto in CargaProjetos do
  begin
    if projeto.Nome <> 'Sem projeto' then
      combobox.Items.Add(projeto.Nome);
  end;
end;

procedure TFrmCadastroProjeto.AtualizarCorSelecionada(var clBxSlc: TColorListBox;
                                                      const indiceCorSlc: Integer);
begin
  AtualizarCorETextoPreview;
  CoresSelecionadas[indiceCorSlc] := clBxSlc.Selected;
end;

procedure TFrmCadastroProjeto.ExecutarCargaDeDados;
begin
  GerenciadorProjeto.LocalizarTodos(CargaProjetos);
  GerenciadorCores.LocalizarTodas(CargaTonalidades);
end;

procedure TFrmCadastroProjeto.AtualizarDescricaoVisualizacao(const acao, projeto: String);
begin
  GpBxProj.Caption := Format('%s %s', [acao, projeto]);
end;

destructor TFrmCadastroProjeto.Destroy;
begin
  if Assigned(CargaProjetos) then
    CargaProjetos.Free;

  if Assigned(CargaTonalidades) then
    CargaTonalidades.Free;

  SetLength(CoresSelecionadas, 0);
  inherited;
end;

end.
