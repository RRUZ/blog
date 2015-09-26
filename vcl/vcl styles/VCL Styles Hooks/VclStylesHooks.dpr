program VclStylesHooks;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {FrmMain},
  uVCLStyleUtils in 'uVCLStyleUtils.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
