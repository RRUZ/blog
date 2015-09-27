{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  Variants,
  ComObj;

//This code that adds a per interface rule using the Microsoft Windows Firewall APIs.
Procedure AddPerInterfaceRule;
Const
 NET_FW_IP_PROTOCOL_TCP = 6;
 NET_FW_IP_PROTOCOL_UDP = 17;
 NET_FW_ACTION_ALLOW = 1;
var
 CurrentProfiles : OleVariant;
 fwPolicy2       : OleVariant;
 RulesObject     : OleVariant;
 NewRule         : OleVariant;
begin
  // Create the FwPolicy2 object.
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;

  //Create a Rule Object.
  NewRule := CreateOleObject('HNetCfg.FWRule');

  NewRule.Name := 'Per_Interface_Rule';
  NewRule.Description := 'Add a Per Interface Rule';
  NewRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  NewRule.LocalPorts := 2300;
  NewRule.Interfacetypes := 'LAN';
  NewRule.Enabled := True;
  NewRule.Grouping := 'My Group';
  NewRule.Profiles := CurrentProfiles;
  NewRule.Interfaces := VarArrayOf(['Local Area Connection']);
  NewRule.Action := NET_FW_ACTION_ALLOW;

  //Add a new rule
  RulesObject.Add(NewRule);
end;

begin
 try
    CoInitialize(nil);
    try
      AddPerInterfaceRule;
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