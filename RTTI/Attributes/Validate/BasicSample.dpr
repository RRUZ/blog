// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program BasicSample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  REST.JSON,
  System.IOUtils,
  System.SysUtils,
  System.Classes,
  uValidation in 'uValidation.pas';

type
  TSettings = class
  private
    FServer: string;
    FPort: Integer;
    FDatabase: string;
    FUser: string;
    FPassword: string;
  public
    [Mandatory, IPAddress]
    property Server  : string read FServer write FServer;
    [Range(1024, 32000)]
    property Port  : Integer read FPort write FPort;
    [Mandatory]
    property DatabaseName : string read FDatabase write FDatabase;
    [Mandatory]
    property User  : string read FUser write FUser;
    [Mandatory, Encrypted]
    property Password  : string read FPassword write FPassword;
    procedure Save;
    class function Load : TSettings;
  end;


{ TSettings }

class function TSettings.Load: TSettings;
//var
//  ConfFile, JsonStr : string;
begin
//  ConfFile := ChangeFileExt(ParamStr(0),'.conf');
//  if TFile.Exists(ConfFile) then
//  begin
//    JsonStr:= StringReplace(TFile.ReadAllText(ConfFile), sLineBreak, '', [rfReplaceAll]);
//    Result := TJson.JsonToObject<TSettings>(JsonStr);
//  end
//  else
    Result:=TSettings.Create;
end;


procedure TSettings.Save;
begin
  TFile.WriteAllText(ChangeFileExt(ParamStr(0),'.conf'), TJson.Format(TJson.ObjectToJsonObject(Self)));
end;

procedure Test;
var
  LSettings : TSettings;
  LResult   : TStrings;
begin
  LSettings:=TSettings.Load;
  try
    LSettings.Server := '10.10.192.165';
    LSettings.DatabaseName := 'Customers_db';
    LSettings.User:='admin';
    LSettings.Password := 'admin8900*';
    LSettings.Port := 5000;

    Writeln(TJson.Format(TJson.ObjectToJsonObject(LSettings)));

//    LResult:=TStringList.Create;
//    try
//
//      //Validate the data before to save
//      if not TryValidateObject(LSettings, LResult) then
//       Writeln('validation fails '+sLineBreak+ LResult.Text)
//      else
//       Writeln('validation pass');
//
//     readln;
//    finally
//      LResult.Free;
//    end;

    TryTransformObject(LSettings, tdForward);
    Writeln('After transformation');
    Writeln(TJson.Format(TJson.ObjectToJsonObject(LSettings)));

    TryTransformObject(LSettings, tdBackward);
    Writeln('reverse transformation');
    Writeln(TJson.Format(TJson.ObjectToJsonObject(LSettings)));

    readln;

    LSettings.Save;
  finally
    LSettings.Free;
  end;
end;


begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
     Test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
