// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program CreateSFX;

uses
  Forms,
  MainCreateSFX in 'MainCreateSFX.pas' {FrmCreateSFX},
  Common in 'Common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmCreateSFX, FrmCreateSFX);
  Application.Run;
end.
