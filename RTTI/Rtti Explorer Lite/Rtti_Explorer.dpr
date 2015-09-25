program Rtti_Explorer;

uses
  Forms,
  MainRttiExpl in 'MainRttiExpl.pas' {FrmRTTIExplLite};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmRTTIExplLite, FrmRTTIExplLite);
  Application.Run;
end.
