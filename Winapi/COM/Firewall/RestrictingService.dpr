{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj;

// This code restricts a service using the Microsoft Windows Firewall APIs.
Procedure RestrictService;
Const
  NET_FW_PROFILE2_DOMAIN = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC = 4;

  NET_FW_IP_PROTOCOL_TCP = 6;

  NET_FW_RULE_DIR_IN = 1;
  NET_FW_RULE_DIR_OUT = 2;

  NET_FW_ACTION_BLOCK = 0;
  NET_FW_ACTION_ALLOW = 1;

var
  fwPolicy2: OleVariant;
  RulesObject, wshRules: OleVariant;
  ServiceRestriction, NewInboundRule, NewOutboundRule: OleVariant;
begin
  // Create the FwPolicy2 object.
  fwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;

  // Get the Service Restriction object for the local firewall policy.
  ServiceRestriction := fwPolicy2.ServiceRestriction;

  // Put in block-all inbound and block-all outbound Windows Service Hardening (WSH) networking rules for the service
  ServiceRestriction.RestrictService('TermService', '%systemDrive%\WINDOWS\system32\svchost.exe', True, False);

  // If the service requires sending/receiving certain type of traffic, then add "allow" WSH rules as follows

  // Get the collection of Windows Service Hardening networking rules
  wshRules := ServiceRestriction.Rules;

  // Add inbound WSH allow rules
  NewInboundRule := CreateOleObject('HNetCfg.FWRule');
  NewInboundRule.Name := 'Allow only TCP 3389 inbound to service';
  NewInboundRule.ApplicationName := '%systemDrive%\WINDOWS\system32\svchost.exe';
  NewInboundRule.ServiceName := 'TermService';
  NewInboundRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  NewInboundRule.LocalPorts := 3389;

  NewInboundRule.Action := NET_FW_ACTION_ALLOW;
  NewInboundRule.Direction := NET_FW_RULE_DIR_IN;
  NewInboundRule.Enabled := True;

  wshRules.Add(NewInboundRule);

  // Add outbound WSH allow rules
  NewOutboundRule := CreateOleObject('HNetCfg.FWRule');
  NewOutboundRule.Name := 'Allow outbound traffic from service only from TCP 3389';
  NewOutboundRule.ApplicationName :='%systemDrive%\WINDOWS\system32\svchost.exe';
  NewOutboundRule.ServiceName := 'TermService';
  NewOutboundRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  NewOutboundRule.LocalPorts := 3389;

  NewOutboundRule.Action := NET_FW_ACTION_ALLOW;
  NewOutboundRule.Direction := NET_FW_RULE_DIR_OUT;
  NewOutboundRule.Enabled := True;

  wshRules.Add(NewOutboundRule);
end;

begin
  try
    CoInitialize(nil);
    try
      RestrictService;
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
