program TcpGeoConnections;

uses
  Forms,
  MainGeoTcpConn in 'MainGeoTcpConn.pas' {FrmMain},
  NetHelperFuncs in 'NetHelperFuncs.pas',
  IpHelperApi in 'IpHelperApi.pas',
  MapsHelper in 'MapsHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
