unit uControleCor;

interface

uses
  uRepo,
  uSQLAttr,
  D16Utils,
  Vcl.Graphics,
  FireDAC.Comp.Client,
  System.Generics.Collections;

type
  [TDbTable('controleferias.cores')]
  TCorTonalidade = class

    const clNmCor = 'NmCor';
    const clHexCor = 'HexCor';
    const clCategoria = 'Categoria';

    private
      [TDbField(clNmCor)]
      fNomeCor : String;

      [TDbField(clHexCor)]
      fCorHex : String;

      [TDbField(clCategoria)]
      fCategoria : String;

      function GetCorReal(): TColor;

    public
      property Nome : String read fNomeCor;
      property Categoria : String read fCategoria;
      property Cor : TColor read GetCorReal;

  end;

  TDAOCorTon = class (TFdRTDao<TCorTonalidade>) end;

  TGerenciadorCores = class
    private
      fDaoCorTon : TDAOCorTon;

    protected
      property DaoCorTon : TDAOCorTon read fDaoCorTon;

    public
      constructor Create(var fdConnection: TFDConnection);
      function GetCoresPorCategoria(const categoria: String; out cores: TList<TCorTonalidade>) : Boolean;
      function LocalizarTodas(out cores: TList<TCorTonalidade>) : Boolean;
  end;

var
  GerenciadorCores : TGerenciadorCores;

implementation

constructor TGerenciadorCores.Create(var fdConnection: TFDConnection);
begin
  fDaoCorTon := TDAOCorTon.Create(fdConnection);
end;

function TGerenciadorCores.LocalizarTodas(out cores: TList<TCorTonalidade>) : Boolean;
begin
  Result := DaoCorTon.FindAll(cores);
end;

function TGerenciadorCores.GetCoresPorCategoria(const categoria: String; out cores: TList<TCorTonalidade>) : Boolean;
begin
  Result := DaoCorTon.Find(categoria, TCorTonalidade.clCategoria, cores);
end;

function TCorTonalidade.GetCorReal(): TColor;
begin
  Result := TUtil.HexToColor(fCorHex);
end;

end.
