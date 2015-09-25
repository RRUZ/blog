program WMIFileExplorer;

uses
  Forms,
  uMain in 'uMain.pas' {FrmMain},
  uStackTrace in 'uStackTrace.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
