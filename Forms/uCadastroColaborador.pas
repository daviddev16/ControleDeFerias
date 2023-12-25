unit uCadastroColaborador;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  uGerenciadores,
  uControleColaborador, Vcl.NumberBox;

type
  TFrmCadastroColaborador = class(TForm)
    EdtLogin: TLabeledEdit;
    EdtDescricao: TLabeledEdit;
    StaticText1: TStaticText;
    MmObservacao: TMemo;
    BtnCadastrar: TButton;
    NmbEdtPrevisaoDias: TNumberBox;
    StaticText2: TStaticText;
    procedure BtnCadastrarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadastroColaborador: TFrmCadastroColaborador;

implementation

{$R *.dfm}

procedure TFrmCadastroColaborador.BtnCadastrarClick(Sender: TObject);
var
  Colaborador : TColaborador;
begin
  ModalResult := mrOk;
  Colaborador := TColaborador.Create;
  Colaborador.Login := EdtLogin.Text;
  Colaborador.Descricao := EdtDescricao.Text;
  Colaborador.Observacao := MmObservacao.Text;
  Colaborador.TotalDiasPrevistos := NmbEdtPrevisaoDias.ValueInt;
  Colaborador.StAtivo := True;
  Colaborador.DataCadastro := Now;

  GerenciadorColaborador.CriarColaborador(Colaborador);
  CloseModal;
  
end;

end.
