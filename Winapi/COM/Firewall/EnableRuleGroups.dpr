{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj;

//This code enables the Windows Firewall rule groups using the Microsoft Windows Firewall APIs.
Procedure EnableRuleGroups;
var
 CurrentProfiles : Integer;
 fwPolicy2       : OleVariant;
 RulesObject     : OleVariant;
begin
  // Create the FwPolicy2 object.
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;
  fwPolicy2.EnableRuleGroup(CurrentProfiles, 'File and Printer Sharing', True);
end;

begin
 try
    CoInitialize(nil);
    try
      EnableRuleGroups;
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