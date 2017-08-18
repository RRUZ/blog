{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj;

// This code adds a Generic Routing Encapsulation (GRE) protocol rule
// using the Microsoft Windows Firewall APIs.
Procedure AddProtocolRule;
Const
  NET_FW_ACTION_ALLOW = 1;
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

  NewRule.Name := 'GRE_RULE';
  NewRule.Description := 'Allow GRE Traffic';
  NewRule.Protocol := 47;
  NewRule.Enabled := True;
  NewRule.Profiles := CurrentProfiles;
  NewRule.Action := NET_FW_ACTION_ALLOW;

  // Add a new rule
  RulesObject.Add(NewRule);
end;

begin
  try
    CoInitialize(nil);
    try
      AddProtocolRule;
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
