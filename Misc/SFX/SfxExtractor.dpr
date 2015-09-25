// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program SfxExtractor;

uses
  Forms,
  MainSFX in 'MainSFX.pas' {FrmMain},
  Common in 'Common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
