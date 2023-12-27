unit uSelecaoProjeto;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Buttons,
  D16Grids,
  uControleColaborador,
  uControleProjeto,
  D16Utils;


type
  TFrmSelecaoProjeto = class(TForm)
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label2: TLabel;
    LsBxColabProjetos: TListBox;
    LsBxTodosProjetos: TListBox;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    ColaboradorSelecionado : TColaborador;

    procedure CarregarProjetosDoSistema;
    procedure CarregarProjetosDoColaborador;

  public
      constructor Create(var colaborador: TColaborador; AOwner: TComponent);

  end;

implementation

constructor TFrmSelecaoProjeto.Create(var colaborador: TColaborador; AOwner: TComponent);
begin
  ColaboradorSelecionado := colaborador;
  inherited Create(AOwner);
end;

procedure TFrmSelecaoProjeto.FormShow(Sender: TObject);
begin
  CarregarProjetosDoSistema;
  CarregarProjetosDoColaborador;
  TUtil.CenterForm(Self);
end;

procedure TFrmSelecaoProjeto.SpeedButton1Click(Sender: TObject);
var
  NomeProjeto : String;
begin
  if LsBxTodosProjetos.ItemIndex <> -1 then
  begin
    NomeProjeto := LsBxTodosProjetos.Items[LsBxTodosProjetos.ItemIndex];
    GerenciadorColaborador.AdicionarProjeto(ColaboradorSelecionado.Id, NomeProjeto);
  end;
  CarregarProjetosDoColaborador;
end;

procedure TFrmSelecaoProjeto.SpeedButton2Click(Sender: TObject);
var
  NomeProjeto : String;
begin
  if LsBxColabProjetos.ItemIndex <> -1 then
  begin
    NomeProjeto := LsBxColabProjetos.Items[LsBxColabProjetos.ItemIndex];
    GerenciadorColaborador.RemoverProjeto(ColaboradorSelecionado.Id, NomeProjeto);
  end;
  CarregarProjetosDoColaborador;
end;

procedure TFrmSelecaoProjeto.CarregarProjetosDoColaborador;
var
  CargaProjetos : TList<TProjeto>;
begin
  try
    LsBxColabProjetos.Items.Clear;
    if GerenciadorProjeto.LocalizarProjetoPorIdColaborador(ColaboradorSelecionado.Id, CargaProjetos) then
    begin
      for var projeto in CargaProjetos do
      begin
        LsBxColabProjetos.Items.Add(projeto.Nome);
      end;
    end;
  finally
    if Assigned(CargaProjetos) then
      FreeAndNil(CargaProjetos);
  end;
end;

procedure TFrmSelecaoProjeto.CarregarProjetosDoSistema;
var
  CargaProjetos : TList<TProjeto>;
begin
  try
    LsBxTodosProjetos.Items.Clear;
    if GerenciadorProjeto.LocalizarTodos(CargaProjetos) then
    begin
      for var projeto in CargaProjetos do
      begin
        LsBxTodosProjetos.Items.Add(projeto.Nome);
      end;
    end;
  finally
    if Assigned(CargaProjetos) then
      FreeAndNil(CargaProjetos);
  end;
end;

{$R *.dfm}



end.
