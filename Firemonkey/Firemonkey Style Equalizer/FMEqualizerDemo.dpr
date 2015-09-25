program FMEqualizerDemo;

uses
  FMX.Forms,
  uMain in 'uMain.pas' {FrmMain},
  uFMEqualizer in 'uFMEqualizer.pas',
  uFrmStyleEqualizer in 'uFrmStyleEqualizer.pas' {FrmStyleEqualizer};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
