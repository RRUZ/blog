//reference https://theroadtodelphi.wordpress.com/2011/08/02/reading-the-smbios-tables-using-delphi/
{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  ActiveX,
  ComObj,
  uSMBIOS in 'uSMBIOS.pas';

procedure GetMSSmBios_RawSMBiosTablesInfo;
Var
  SMBios : TSMBios;
  UUID   : Array[0..31] of Char;
  Entry  : TSMBiosTableEntry;
begin
  SMBios:=TSMBios.Create;
  try
    With SMBios do
    begin
        Writeln(Format('%d SMBios tables found',[SMBiosTablesList.Count]));
        Writeln('');

        Writeln('Type Handle Length Index');
        for Entry in SMBiosTablesList do
          Writeln(Format('%3d  %4x   %3d    %4d',[Entry.Header.TableType, Entry.Header.Handle, Entry.Header.Length, Entry.Index]));

      Readln;

      if HasBiosInfo then
      begin
        WriteLn('Bios Information');
        WriteLn('Vendor        '+GetSMBiosString(BiosInfoIndex + BiosInfo.Header.Length, BiosInfo.Vendor));
        WriteLn('Version       '+GetSMBiosString(BiosInfoIndex + BiosInfo.Header.Length, BiosInfo.Version));
        WriteLn('Start Segment '+IntToHex(BiosInfo.StartingSegment,4));
        WriteLn('ReleaseDate   '+GetSMBiosString(BiosInfoIndex + BiosInfo.Header.Length, BiosInfo.ReleaseDate));
        WriteLn(Format('Bios Rom Size %d k',[64*(BiosInfo.BiosRomSize+1)]));
        WriteLn('');
      end;

      if HasSysInfo then
      begin
        WriteLn('System Information');
        WriteLn('Manufacter    '+GetSMBiosString(SysInfoIndex + SysInfo.Header.Length, SysInfo.Manufacturer));
        WriteLn('Product Name  '+GetSMBiosString(SysInfoIndex + SysInfo.Header.Length, SysInfo.ProductName));
        WriteLn('Version       '+GetSMBiosString(SysInfoIndex + SysInfo.Header.Length, SysInfo.Version));
        WriteLn('Serial Number '+GetSMBiosString(SysInfoIndex + SysInfo.Header.Length, SysInfo.SerialNumber));
        BinToHex(@SysInfo.UUID,UUID,SizeOf(SysInfo.UUID));
        WriteLn('UUID          '+UUID);

        WriteLn('');
      end;

      if HasBaseBoardInfo then
      begin
        WriteLn('BaseBoard Information');
        WriteLn('Manufacter    '+GetSMBiosString(BaseBoardInfoIndex + BaseBoardInfo.Header.Length, BaseBoardInfo.Manufacturer));
        WriteLn('Product       '+GetSMBiosString(BaseBoardInfoIndex + BaseBoardInfo.Header.Length, BaseBoardInfo.Product));
        WriteLn('Version       '+GetSMBiosString(BaseBoardInfoIndex + BaseBoardInfo.Header.Length, BaseBoardInfo.Version));
        WriteLn('Serial Number '+GetSMBiosString(BaseBoardInfoIndex + BaseBoardInfo.Header.Length, BaseBoardInfo.SerialNumber));
        WriteLn('');
      end;

      if HasEnclosureInfo then
      begin
        WriteLn('Enclosure Information');
        WriteLn('Manufacter    '+GetSMBiosString(EnclosureInfoIndex + EnclosureInfo.Header.Length, EnclosureInfo.Manufacturer));
        WriteLn('Version       '+GetSMBiosString(EnclosureInfoIndex + EnclosureInfo.Header.Length, EnclosureInfo.Version));
        WriteLn('Serial Number '+GetSMBiosString(EnclosureInfoIndex + EnclosureInfo.Header.Length, EnclosureInfo.SerialNumber));
        WriteLn('Asset Tag Number '+GetSMBiosString(EnclosureInfoIndex + EnclosureInfo.Header.Length, EnclosureInfo.AssetTagNumber));
        WriteLn('');
      end;

      if HasProcessorInfo then
      begin
        WriteLn('Processor Information');
        WriteLn('Socket Designation     '+GetSMBiosString(ProcessorInfoIndex + ProcessorInfo.Header.Length, ProcessorInfo.SocketDesignation));
        WriteLn('Processor Manufacturer '+GetSMBiosString(ProcessorInfoIndex + ProcessorInfo.Header.Length, ProcessorInfo.ProcessorManufacturer));
        WriteLn('Serial Number          '+GetSMBiosString(ProcessorInfoIndex + ProcessorInfo.Header.Length, ProcessorInfo.SerialNumber));
        WriteLn('Asset Tag              '+GetSMBiosString(ProcessorInfoIndex + ProcessorInfo.Header.Length, ProcessorInfo.AssetTag));
        WriteLn('Part Number            '+GetSMBiosString(ProcessorInfoIndex + ProcessorInfo.Header.Length, ProcessorInfo.PartNumber));
        WriteLn('');
      end;
    end;
  finally
   SMBios.Free;
  end;
end;

begin
 try
    CoInitialize(nil);
    try
      GetMSSmBios_RawSMBiosTablesInfo;
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