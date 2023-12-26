program ControleDeFerias_11_3;



{$R *.dres}

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uControleProjeto in 'Controle\uControleProjeto.pas',
  uControleUsuario in 'Controle\uControleUsuario.pas',
  uGerenciadores in 'Controle\uGerenciadores.pas',
  uControleColaborador in 'Controle\uControleColaborador.pas',
  uControleConfiguracao in 'Controle\uControleConfiguracao.pas',
  LoginDialog in 'Forms\LoginDialog.pas',
  uCadastroFerias in 'Forms\uCadastroFerias.pas',
  uPrincipal in 'Forms\uPrincipal.pas' {FormPrincipal},
  uPrinVisualGrid in 'Componentes\uPrinVisualGrid.pas',
  uVisualMiscs in 'Miscs\uVisualMiscs.pas',
  uCargaStatus in 'Componentes\uCargaStatus.pas' {CarregamentoStatus},
  uFeriasVisualGrid in 'Componentes\uFeriasVisualGrid.pas',
  uSelecaoPeriodos in 'Forms\uSelecaoPeriodos.pas' {FrmSelecaoPeriodo},
  uValidacaoSimples in 'Componentes\uValidacaoSimples.pas' {FrmValidacaoSimples},
  uInformativo in 'Forms\uInformativo.pas' {FrmInformativo},
  uCadastroProjeto in 'Forms\uCadastroProjeto.pas' {FrmCadastroProjeto},
  uControleCor in 'Controle\uControleCor.pas',
  uGerenciadorColaborador in 'Forms\uGerenciadorColaborador.pas',
  uOpcoes in 'Forms\uOpcoes.pas' {FrmOpcoes};

{$R *.res}
//{$APPTYPE CONSOLE}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('ControleFerias');
  Application.Title := 'Controle de férias';
  TGerenciador.Inicializar;

  Application.CreateForm(TLoginForm, LoginForm);
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;

end.
