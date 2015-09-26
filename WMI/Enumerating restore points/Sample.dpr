//Author Rodrigo Ruz 14/04/2010.
{$APPTYPE CONSOLE}

uses
  SysUtils
  ,ActiveX
  ,ComObj
  ,Variants;

function RestorePointTypeToStr(RestorePointType:Integer):string;
begin
     case  RestorePointType of
      0  : Result:='APPLICATION_INSTALL';
      1  : Result:='APPLICATION_UNINSTALL';
      13 : Result:='CANCELLED_OPERATION';
      10 : Result:='DEVICE_DRIVER_INSTALL';
      12 : Result:='MODIFY_SETTINGS'
      else
      Result:='Unknow';
     end;
end;

function EventTypeToStr(EventType:integer) : string;
begin
     case  EventType of
      102  : Result:='BEGIN_NESTED_SYSTEM_CHANGE';
      100  : Result:='BEGIN_SYSTEM_CHANGE';
      103  : Result:='END_NESTED_SYSTEM_CHANGE';
      101  : Result:='END_SYSTEM_CHANGE'
      else
      Result:='Unknow';
     end;
end;

function WMITimeToStr(WMITime:string) : string; //convert to dd/mm/yyyy hh:mm:ss
begin
    //20020710113047.000000420-000 example    source http://technet.microsoft.com/en-us/library/ee156576.aspx
    result:=Format('%s/%s/%s %s:%s:%s',[copy(WMITime,7,2),copy(WMITime,5,2),copy(WMITime,1,4),copy(WMITime,9,2),copy(WMITime,11,2),copy(WMITime,13,2)]);
end;

procedure GetRestorePoints;
var
  oSWbemLocator : OLEVariant;
  objWMIService : OLEVariant;
  colItems      : OLEVariant;
  colItem       : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
begin
  oSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  objWMIService := oSWbemLocator.ConnectServer('localhost', 'root\default', '', '');
  colItems      := objWMIService.ExecQuery('SELECT * FROM SystemRestore','WQL',0);
  oEnum         := IUnknown(colItems._NewEnum) as IEnumVariant;
  while oEnum.Next(1, colItem, iValue) = 0 do
  begin
      WriteLn(Format('%s %-15s',['Description',colItem.Description]));
      WriteLn(Format('%s %-15s',['RestorePointType',RestorePointTypeToStr(colItem.RestorePointType)]));
      WriteLn(Format('%s %-15s',['EventType',EventTypeToStr(colItem.EventType)]));
      WriteLn(Format('%s %-15s',['SequenceNumber',colItem.SequenceNumber]));
      WriteLn(Format('%s %-15s',['CreationTime',WMITimeToStr(colItem.CreationTime)]));
      Writeln;
      colItem:=Unassigned;
  end;
end;

begin
 try
    CoInitialize(nil);
    try
      GetRestorePoints;
    finally
      CoUninitialize;
    end;
 except
    on E:Exception do
        Writeln(E.Classname, ': ', E.Message);       
  end;
  Readln;
end.