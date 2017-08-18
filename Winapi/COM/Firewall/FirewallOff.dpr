{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj;

// This code that disables the firewall using the Microsoft Windows Firewall APIs.
Procedure SetFirewallOff;
Const
  NET_FW_PROFILE2_DOMAIN = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC = 4;
var
  fwPolicy2: OleVariant;
begin
  // Create the FwPolicy2 object.
  fwPolicy2 := CreateOleObject('HNetCfg.FwPolicy2');

  fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_DOMAIN] := False;
  fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_PRIVATE] := False;
  fwPolicy2.FirewallEnabled[NET_FW_PROFILE2_PUBLIC] := False;
end;

begin
  try
    CoInitialize(nil);
    try
      SetFirewallOff;
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
