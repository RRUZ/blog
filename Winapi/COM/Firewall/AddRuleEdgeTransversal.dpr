{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj;

// This code adds an application rule with Edge Traversal using the Microsoft Windows Firewall APIs.
Procedure AddRuleEdgeTraversal;
Const
  NET_FW_ACTION_ALLOW = 1;
  NET_FW_IP_PROTOCOL_TCP = 6;
var
  CurrentProfiles: OleVariant;
  fwPolicy2: OleVariant;
  RulesObject: OleVariant;
  NewRule: OleVariant;
begin
  // Create the FwPolicy2 object.
  fwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;

  // Create a Rule Object.
  NewRule := CreateOleObject('HNetCfg.FWRule');

  NewRule.Name := 'My Application Name with Edge Traversal';
  NewRule.Description := 'Allow GRE TrafficAllow my application network traffic with Edge Traversal';
  NewRule.Applicationname := 'MyApplication.exe';
  NewRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  NewRule.LocalPorts := 5000;
  NewRule.Enabled := True;
  NewRule.Grouping := 'My Group';
  NewRule.Profiles := CurrentProfiles;
  NewRule.Action := NET_FW_ACTION_ALLOW;
  NewRule.EdgeTraversal := True;

  // Add a new rule
  RulesObject.Add(NewRule);
end;

begin
  try
    CoInitialize(nil);
    try
      AddRuleEdgeTraversal;
    finally
      CoUninitialize;
    end;
  except
    on E: EOleException do
      Writeln(Format('EOleException %s %x', [E.Message, E.ErrorCode]));
    on E: Exception do
      Writeln(E.Classname, ':', E.Message);
  end;
  Writeln('Press Enter to exit');
  Readln;

end.
