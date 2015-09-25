// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program GeoTracerouteDemo;

uses
  Forms,
  MainDemoGeoInfoTrace in 'MainDemoGeoInfoTrace.pas' {FrmMainTrace},
  NetHelperFuncs in 'NetHelperFuncs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMainTrace, FrmMainTrace);
  Application.Run;
end.
