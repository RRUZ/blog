{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj;

// This code checks if the rule group is enabled in the current profile using the Microsoft Windows Firewall APIs.
Procedure CheckingRuleEnabled;
Const
  NET_FW_MODIFY_STATE_OK = 0;
  NET_FW_MODIFY_STATE_GP_OVERRIDE = 1;
  NET_FW_MODIFY_STATE_INBOUND_BLOCKED = 2;
var
  fwPolicy2: OleVariant;
  PolicyModifyState: Integer;
  bIsEnabled: Boolean;
begin
  // Create the FwPolicy2 object.
  fwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');

  bIsEnabled := fwPolicy2.IsRuleGroupCurrentlyEnabled
    ('File and Printer Sharing');

  if bIsEnabled then
    Writeln('File and Printer Sharing is currently enabled on at least one of the current profiles')
  else
    Writeln('File and Printer Sharing is currently not enabled on any of the current profiles');

  PolicyModifyState := fwPolicy2.LocalPolicyModifyState;

  case PolicyModifyState of
    NET_FW_MODIFY_STATE_OK:
      Writeln('Changing or adding a firewall rule (or group) will take effect on at least one of the current profiles.');
    NET_FW_MODIFY_STATE_GP_OVERRIDE:
      Writeln('Changing or adding a firewall rule (or group) to the current profiles will not take effect because group policy overrides it on at least one of the current profiles.');
    NET_FW_MODIFY_STATE_INBOUND_BLOCKED:
      Writeln('Changing or adding an inbound firewall rule (or group) to the current profiles will not take effect because inbound rules are not allowed on at least one of the current profiles.')
  else
    Writeln('Invalid Modify State returned by LocalPolicyModifyState.');
  End;

end;

begin
  try
    CoInitialize(nil);
    try
      CheckingRuleEnabled;
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
