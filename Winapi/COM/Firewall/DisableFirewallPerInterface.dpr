{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  Variants,
  ComObj;

// This code disables the firewall on a per interface basis using the Microsoft Windows Firewall APIs.
Procedure DisableFirewallPerInterface;
Const
  NET_FW_PROFILE2_DOMAIN = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC = 4;
var
  CurrentProfiles: Integer;
  fwPolicy2: OleVariant;
begin
  // Create the FwPolicy2 object.
  fwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;

  // Disable Firewall on interface in the Domain profile
  if (CurrentProfiles and NET_FW_PROFILE2_DOMAIN) <> 0 then
  begin
    if not fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_DOMAIN] then
      fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_DOMAIN] := True;

    fwPolicy2.ExcludedInterfaces(NET_FW_PROFILE2_DOMAIN, VarArrayOf(['Local Area Connection']));
  end;

  // Disable Firewall on interface in the Private profile
  if (CurrentProfiles and NET_FW_PROFILE2_PRIVATE) <> 0 then
  begin
    if not fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_PRIVATE] then
      fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_PRIVATE] := True;

    fwPolicy2.ExcludedInterfaces(NET_FW_PROFILE2_PRIVATE, VarArrayOf(['Local Area Connection']));
  end;

  // Disable Firewall on interface in the Public profile
  if (CurrentProfiles and NET_FW_PROFILE2_PUBLIC) <> 0 then
  begin
    if not fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_PUBLIC] then
      fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_PUBLIC] := True;

    fwPolicy2.ExcludedInterfaces(NET_FW_PROFILE2_PUBLIC, VarArrayOf(['Local Area Connection']));
  end;

end;

begin
  try
    CoInitialize(nil);
    try
      DisableFirewallPerInterface;
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
