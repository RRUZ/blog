program ListProcesses;

uses
  FMX.Forms,
  uMain in 'uMain.pas' {Form25};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm25, Form25);
  Application.Run;
end.
