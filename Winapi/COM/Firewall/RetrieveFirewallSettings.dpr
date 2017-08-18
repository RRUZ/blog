{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj;

// This code reads the Windows Firewall settings per profile using the Microsoft Windows Firewall APIs.
Procedure GetFirewallSettings;
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

  if (CurrentProfiles AND NET_FW_PROFILE2_DOMAIN) <> 0 then
    if fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_DOMAIN] then
      Writeln('Firewall is ON on domain profile.')
    else
      Writeln('Firewall is OFF on domain profile.');

  if (CurrentProfiles AND NET_FW_PROFILE2_PRIVATE) <> 0 then
    if fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_PRIVATE] then
      Writeln('Firewall is ON on private profile.')
    else
      Writeln('Firewall is OFF on private profile.');

  if (CurrentProfiles AND NET_FW_PROFILE2_PUBLIC) <> 0 then
    if fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_PUBLIC] then
      Writeln('Firewall is ON on public profile.')
    else
      Writeln('Firewall is OFF on public profile.');
end;

begin
  try
    CoInitialize(nil);
    try
      GetFirewallSettings;
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
