//reference https://theroadtodelphi.wordpress.com/2012/01/06/determine-genuine-windows-installation-using-delphi/
{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj,
  Variants;

procedure  GetWin32_WindowsProductActivationInfo;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
begin;

  if (Win32MajorVersion=5) and (Win32MinorVersion=1) then
  begin
    NullStrictConvert :=False;
    FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
    FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_WindowsProductActivation','WQL',wbemFlagForwardOnly);
    oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
    while oEnum.Next(1, FWbemObject, iValue) = 0 do
    begin
      Writeln(Format('Windows is Activated  %s',[BooltoStr(FWbemObject.ActivationRequired=0,True)]));
      Writeln(Format('ActivationRequired    %d',[Integer(FWbemObject.ActivationRequired)]));
      Writeln(Format('Description           %s',[String(FWbemObject.Description)]));
      Writeln(Format('ProductID             %s',[String(FWbemObject.ProductID)]));
      if FWbemObject.ActivationRequired=1 then
      begin
        Writeln(Format('RemainingEvaluationPeriod    %d',[Integer(FWbemObject.RemainingEvaluationPeriod)]));
        Writeln(Format('RemainingGracePeriod         %d',[Integer(FWbemObject.RemainingGracePeriod)]));
      end;
      Writeln(Format('ServerName            %s',[String(FWbemObject.ServerName)]));
      Writeln(Format('SettingID             %s',[String(FWbemObject.SettingID)]));

      Writeln;
      FWbemObject:=Unassigned;
    end;
  end
  else
  Writeln('OS not supported');
end;


begin
 try
    CoInitialize(nil);
    try
      GetWin32_WindowsProductActivationInfo;
    finally
      CoUninitialize;
    end;
 except
    on E:EOleException do
        Writeln(Format('EOleException %s %x', [E.Message,E.ErrorCode]));
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln('Press Enter to exit');
 Readln;
end.