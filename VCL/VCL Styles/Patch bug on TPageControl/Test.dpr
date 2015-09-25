program Test;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {FrmMain},
  uXE2Patches in 'uXE2Patches.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
