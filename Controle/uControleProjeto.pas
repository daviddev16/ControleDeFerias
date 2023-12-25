unit uControleProjeto;

interface

uses
  SysUtils,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  uValidacaoSimples,
  uRepo,
  uSQLAttr,
  uUtility,
  FireDAC.Comp.Client,
  FireDac.Stan.Error;

type

  [TDbTable('controleferias.projeto')]
  TProjeto = class

    const cfIdProj  = 'IdProjeto';
    const cfNmProj  = 'NmProjeto';
    const cfDsProj  = 'DsProjeto';
    const cfClFundo = 'ClFundo';
    const cfClTexto = 'ClTexto';

    private
      [TDbSeqId]
      [TDbField(cfIdProj)]
      fIdProjeto : Integer;

      [TDbField(cfNmProj)]
      fNome      : String;

      [TDbField(cfDsProj)]
      fDescricao : String;

      [TDbField(cfClTexto)]
      fCorTexto  : String;

      [TDbField(cfClFundo)]
      fCorFundo  : String;

    public
      property IdProjeto : Integer read fIdProjeto;
      property Nome : String read fNome write fNome;
      property Descricao : String read fDescricao write fDescricao;
      property CorTexto : String read fCorTexto write fCorTexto;
      property CorFundo : String read fCorFundo write fCorFundo;

  end;

  TDAOProjeto = class(TFdRTDao<TProjeto>) end;

  TGerenciadorProjeto = class(TInterfacedObject, IDbErrorHandler)
    private
      fDaoProjeto : TDAOProjeto;

      procedure HandleException(exception: EFDDBEngineException);

    protected
      property DaoProjeto : TDAOProjeto read fDaoProjeto;

    public

      procedure AtualizarProjetoPorId(const idProjeto: Integer; alteracoes: TDictionary<String, Variant>);
      function CadastrarProjeto(novoProjeto: TProjeto): Boolean;
      procedure DeletarPorId(const idProjeto: Integer);

      function LocalizarPorId(projetoId: Integer; out projeto: TProjeto): Boolean;
      function LocalizarPorNome(nome: String; out projeto: TProjeto): Boolean;
      function LocalizarTodos(out projetos: TList<TProjeto>): Boolean;
      constructor Create(var fdConnection: TFDConnection);

  end;

var
  GerenciadorProjeto : TGerenciadorProjeto;

implementation

constructor TGerenciadorProjeto.Create(var fdConnection: TFDConnection);
begin
  fDaoProjeto := TDAOProjeto.Create(fdConnection);
  fDaoProjeto.ErrorHandler := Self;
  WriteLn('GerenciadorProjeto criado com sucesso.');
end;

procedure TGerenciadorProjeto.AtualizarProjetoPorId(const idProjeto: Integer;
                                               alteracoes: TDictionary<String, Variant>);
begin
  DaoProjeto.Update(TProjeto.cfIdProj, idProjeto, alteracoes);
end;

procedure TGerenciadorProjeto.DeletarPorId(const idProjeto: Integer);
begin
  DaoProjeto.Delete(TProjeto.cfIdProj, idProjeto);
end;

function TGerenciadorProjeto.CadastrarProjeto(novoProjeto: TProjeto): Boolean;
begin
  Result := DaoProjeto.Insert(novoProjeto);
end;

function TGerenciadorProjeto.LocalizarPorNome(nome: String; out projeto: TProjeto): Boolean;
begin
  Result := DaoProjeto.FindUnique(nome, TProjeto.cfNmProj, projeto);
end;

function TGerenciadorProjeto.LocalizarTodos(out projetos: TList<TProjeto>): Boolean;
begin
  Result := DaoProjeto.FindAll(projetos);
end;

function TGerenciadorProjeto.LocalizarPorId(projetoId: Integer; out projeto: TProjeto): Boolean;
begin
  Result := DaoProjeto.FindUnique(projetoId, TProjeto.cfIdProj, projeto);
end;

procedure TGerenciadorProjeto.HandleException(exception: EFDDBEngineException);
begin
  if (exception.kind = ekUKViolated) or (exception.kind = ekFKViolated) then
  begin
    if SameText(exception[0].ObjName, 'fk_cbproj_idprojeto') then
    begin
      TFrmValidacaoSimples.MostrarValidacao(
        'Operação não permitida.',
        'Não é possível deletar projetos que estão associados a um colaborador.',
        'Será necessário remover dos colaboradores antes.');
    end
    else if (SameText(exception[0].ObjName, 'uq_projetos_nmproj')) then
    begin
      TFrmValidacaoSimples.MostrarValidacao(
        'Operação não permitida.',
        'Já existe um projeto com esse nome.', '');
    end;
  end;
end;

end.
