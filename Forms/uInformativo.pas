unit uInformativo;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TFrmInformativo = class(TForm)
    LblFeature: TLabel;
    MmDescricao: TMemo;
    Image1: TImage;
    LblSubDesc: TLabel;
    Shape1: TShape;
    BtnEntendido: TButton;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    procedure BtnEntendidoClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetDescricao(var linhas: TStringList);
    procedure SetSubDescricao(const subDesc: String);
    procedure SetNome(const nome: String);
    procedure GrudarEm(owner: TForm);

    class function MostrarInformativoRelacaoFerias(owner: TForm): TFrmInformativo;
  end;

implementation

{$R *.dfm}

class function TFrmInformativo.MostrarInformativoRelacaoFerias(owner: TForm) : TFrmInformativo;
var
  Linhas : TStringList;
begin
  Linhas := TStringList.Create;
  Result := TFrmInformativo.Create(nil);
  try
    with Linhas do
    begin
      Add('');
      Add('Propósito:');
      Add('O painel "Relação de férias" vem com o propósito de facilitar a comparação  '+
          'entre períodos de férias de outros colaboradores, com o que está sendo planejado no momento.');
      Add('');
      Add('Período de férias:');
      Add('O painel "Período de férias" apresenta a informação de todos os períodos de férias do colaborador.');
      Add('');
      Add('Como utilizar?');
      Add('Para utilizar o recurso basta selecionar um período válido na grade '+
          '"Períodos", depois, clicar em "Comparar". Na grade "Relação de férias"'+
          ' vai mostrar os colaboradores que possuem períodos de férias com conflito ou não.');
      Add('');
      Add('Quando a coluna "Validação" estiver como "Conflita", significa que o '+
          'período selecionado é igual ou colide com o período de férias do colaborador. Se '+
          'Estiver "Sem conflito", significa que o período selecionado não colide com o período '+
          'de férias do colaborador.');
      Add('');
    end;
    Result.SetNome('Relação de férias');
    Result.SetSubDescricao('Colaboradores 🡒 Editar férias 🡒 Relação de férias');
    Result.SetDescricao(Linhas);
    Result.GrudarEm(owner);
    Result.ShowModal;
  finally
    Linhas.Free;
  end;

end;

procedure TFrmInformativo.GrudarEm(owner: TForm);
begin
  Left := owner.Left + owner.Width;
  Top := owner.Top;
  Height := owner.Height;
end;

procedure TFrmInformativo.BtnEntendidoClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmInformativo.SetSubDescricao(const subDesc: String);
begin
  LblSubDesc.Caption := subDesc;
end;

procedure TFrmInformativo.SetDescricao(var linhas: TStringList);
begin
  MmDescricao.Lines := linhas;
  MmDescricao.CaretPos := Point(-1, -1);
end;

procedure TFrmInformativo.SetNome(const nome: String);
begin
  LblFeature.Caption := nome;
end;


end.
