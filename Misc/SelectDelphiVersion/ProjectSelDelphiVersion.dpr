program ProjectSelDelphiVersion;

uses
  Forms,
  UnitTest in 'UnitTest.pas' {Form9},
  SelectDelphiVersion in 'SelectDelphiVersion.pas' {FrmSelDelphiVer};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm9, Form9);
  Application.Run;
end.
