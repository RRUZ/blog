{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  Variants,
  ComObj;

//This code enumerates Windows Firewall rules using the Microsoft Windows Firewall APIs.
Procedure EnumerateFirewallRules;
Const
  NET_FW_PROFILE2_DOMAIN  = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC  = 4;

  NET_FW_IP_PROTOCOL_TCP = 6;
  NET_FW_IP_PROTOCOL_UDP = 17;
  NET_FW_IP_PROTOCOL_ICMPv4 = 1;
  NET_FW_IP_PROTOCOL_ICMPv6 = 58;

  NET_FW_RULE_DIR_IN = 1;
  NET_FW_RULE_DIR_OUT = 2;

  NET_FW_ACTION_BLOCK = 0;
  NET_FW_ACTION_ALLOW = 1;

var
 CurrentProfiles : Integer;
 fwPolicy2       : OleVariant;
 RulesObject     : OleVariant;
 rule            : OleVariant;
 oEnum           : IEnumvariant;
 iValue          : LongWord;
begin
  // Create the FwPolicy2 object.
  fwPolicy2   := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject := fwPolicy2.Rules;
  CurrentProfiles := fwPolicy2.CurrentProfileTypes;

  if (CurrentProfiles AND NET_FW_PROFILE2_DOMAIN)<>0 then
     Writeln('Domain Firewall Profile is active');

  if ( CurrentProfiles AND NET_FW_PROFILE2_PRIVATE )<>0 then
      Writeln('Private Firewall Profile is active');

  if ( CurrentProfiles AND NET_FW_PROFILE2_PUBLIC )<>0 then
      Writeln('Public Firewall Profile is active');

  Writeln('Rules:');

  oEnum         := IUnknown(Rulesobject._NewEnum) as IEnumVariant;
  while oEnum.Next(1, rule, iValue) = 0 do
  begin
    if (rule.Profiles And CurrentProfiles)<>0 then
    begin
        Writeln('  Rule Name:          ' + rule.Name);
        Writeln('   ----------------------------------------------');
        Writeln('  Description:        ' + rule.Description);
        Writeln('  Application Name:   ' + rule.ApplicationName);
        Writeln('  Service Name:       ' + rule.ServiceName);

        Case rule.Protocol of
           NET_FW_IP_PROTOCOL_TCP    : Writeln('  IP Protocol:        TCP.');
           NET_FW_IP_PROTOCOL_UDP    : Writeln('  IP Protocol:        UDP.');
           NET_FW_IP_PROTOCOL_ICMPv4 : Writeln('  IP Protocol:        UDP.');
           NET_FW_IP_PROTOCOL_ICMPv6 : Writeln('  IP Protocol:        UDP.');
        Else                           Writeln('  IP Protocol:        ' + VarToStr(rule.Protocol));
        End;


        if (rule.Protocol = NET_FW_IP_PROTOCOL_TCP) or (rule.Protocol = NET_FW_IP_PROTOCOL_UDP) then
        begin
          Writeln('  Local Ports:        ' + rule.LocalPorts);
          Writeln('  Remote Ports:       ' + rule.RemotePorts);
          Writeln('  LocalAddresses:     ' + rule.LocalAddresses);
          Writeln('  RemoteAddresses:    ' + rule.RemoteAddresses);
        end;

        if (rule.Protocol = NET_FW_IP_PROTOCOL_ICMPv4) or (rule.Protocol = NET_FW_IP_PROTOCOL_ICMPv6) then
          Writeln('  ICMP Type and Code: ' + rule.IcmpTypesAndCodes);

        Case rule.Direction of
            NET_FW_RULE_DIR_IN :  Writeln('  Direction:          In');
            NET_FW_RULE_DIR_OUT:  Writeln('  Direction:          Out');
        End;

        Writeln('  Enabled:            ' + VarToStr(rule.Enabled));
        Writeln('  Edge:               ' + VarToStr(rule.EdgeTraversal));

        Case rule.Action of
           NET_FW_ACTION_ALLOW : Writeln('  Action:             Allow');
           NET_FW_ACTION_BLOCk : Writeln('  Action:             Block');
        End;


        Writeln('  Grouping:           ' + rule.Grouping);
        Writeln('  Edge:               ' + VarToStr(rule.EdgeTraversal));
        Writeln('  Interface Types:    ' + rule.InterfaceTypes);

     Writeln;
    end;
    rule:=Unassigned;
  end;


end;

begin
 try
    CoInitialize(nil);
    try
      EnumerateFirewallRules;
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